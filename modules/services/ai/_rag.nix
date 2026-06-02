{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;

  # Walks cfg.rag.docsDir, uploads each .md/.txt/.nix file as a Letta Source,
  # and attaches it to all three agents. Idempotent: stale source records are
  # deleted first because Qdrant (the embedding store) is ephemeral — its index
  # is always empty at startup, so old Letta source records would be orphaned.
  ragIndexPy = pkgs.writeText "letta-rag-index.py" ''
    import time, pathlib
    import httpx

    LETTA    = "http://127.0.0.1:${toString cfg.letta.port}"
    DOCS_DIR = pathlib.Path("${cfg.rag.docsDir}")
    EXTS     = {".md", ".txt", ".nix"}
    AGENTS   = ("echo", "coder", "core")

    client = httpx.Client(timeout=60, follow_redirects=True)

    def req(method, path, **kwargs):
        r = client.request(method, f"{LETTA}{path}", **kwargs)
        r.raise_for_status()
        return r.json()

    for _ in range(30):
        try:
            req("GET", "/v1/health")
            break
        except Exception:
            time.sleep(2)
    else:
        raise SystemExit("[rag] Letta not ready")

    if not DOCS_DIR.exists():
        print(f"[rag] {DOCS_DIR} not found — create it and drop .md/.txt/.nix files there.")
        raise SystemExit(0)

    files = sorted(f for f in DOCS_DIR.rglob("*") if f.suffix in EXTS and f.is_file())
    if not files:
        print("[rag] no documents found, nothing to index.")
        raise SystemExit(0)

    print(f"[rag] indexing {len(files)} file(s) from {DOCS_DIR}")

    # Resolve agent IDs
    agent_ids = {}
    for name in AGENTS:
        try:
            agents = req("GET", f"/v1/agents/?name={name}")
            if agents:
                agent_ids[name] = agents[0]["id"]
        except Exception as e:
            print(f"[rag] warning: could not resolve agent {name!r}: {e}")

    # Remove stale source records — Qdrant is wiped on each boot so any
    # existing records point at embeddings that no longer exist.
    try:
        existing = {s["name"]: s["id"] for s in req("GET", "/v1/sources/?limit=500")}
    except Exception:
        existing = {}

    for fpath in files:
        src_name = fpath.stem

        if src_name in existing:
            try:
                client.delete(f"{LETTA}/v1/sources/{existing[src_name]}", timeout=30)
                print(f"[rag] removed stale: {src_name}")
            except Exception as e:
                print(f"[rag] warning: delete {src_name}: {e}")

        try:
            src = req("POST", "/v1/sources/", json={
                "name": src_name,
                "embedding_config": {
                    "embedding_model": "${cfg.models.embed}",
                    "embedding_endpoint_type": "openai",
                    "embedding_endpoint": "http://127.0.0.1:${toString (cfg.litellm.port + 1)}",
                    "embedding_dim": 768,
                },
            })
            src_id = src["id"]
        except Exception as e:
            print(f"[rag] error: create source {src_name}: {e}")
            continue

        try:
            with open(fpath, "rb") as f:
                r = client.post(
                    f"{LETTA}/v1/sources/{src_id}/upload",
                    files={"file": (fpath.name, f, "text/plain")},
                    timeout=120,
                )
                r.raise_for_status()
            file_id = r.json().get("id")
            print(f"[rag] uploaded: {fpath.name} ({file_id})")
        except Exception as e:
            print(f"[rag] error: upload {fpath.name}: {e}")
            continue

        # Wait for async embedding/chunking to finish before attaching
        if file_id:
            for _ in range(30):
                try:
                    file_statuses = req("GET", f"/v1/sources/{src_id}/files")
                    status = next((f["processing_status"] for f in file_statuses if f.get("id") == file_id), "unknown")
                    if status == "completed":
                        break
                    if status == "error":
                        err = next((f.get("error_message", "") for f in file_statuses if f.get("id") == file_id), "")
                        print(f"[rag] error: embedding failed for {fpath.name}: {err[:120]}")
                        file_id = None
                        break
                except Exception:
                    pass
                time.sleep(2)
            else:
                print(f"[rag] warning: timed out waiting for {fpath.name} to embed")

        if not file_id:
            continue

        for agent_name, agent_id in agent_ids.items():
            try:
                r = client.patch(
                    f"{LETTA}/v1/agents/{agent_id}/sources/attach/{src_id}",
                    timeout=30,
                )
                r.raise_for_status()
                print(f"[rag] attached {src_name} → {agent_name}")
            except Exception as e:
                print(f"[rag] warning: attach {src_name} → {agent_name}: {e}")

    # Write the indexed doc list into each agent's human memory block so
    # the model always sees what's available without needing per-message injection.
    doc_list = "\n".join(f"- {f.stem}" for f in files)
    doc_note = f"\n\nIndexed document library (use archival_memory_search to retrieve):\n{doc_list}\nSearch this before answering project-specific questions."

    for agent_name, agent_id in agent_ids.items():
        try:
            memory = req("GET", f"/v1/agents/{agent_id}/core-memory")
            human = next((b for b in memory.get("blocks", []) if b.get("label") == "human"), None)
            if human:
                base = human.get("value", "").split("\n\nIndexed document library")[0].rstrip()
                req("PATCH", f"/v1/blocks/{human['id']}", json={"value": base + doc_note})
                print(f"[rag] updated human block for {agent_name}")
        except Exception as e:
            print(f"[rag] warning: human block update for {agent_name}: {e}")

    print("[rag] indexing complete.")
  '';

  ragIndexScript = pkgs.writeShellScript "letta-rag-index" ''
    exec ${pkgs.letta}/bin/python3.11 ${ragIndexPy}
  '';
in {
  config = lib.mkIf (cfg.letta.enable && cfg.rag.enable) {
    systemd.services.letta-rag-init = {
      description = "Index ~/Documents/data into Letta archival memory";
      after = ["letta-tool-init.service"];
      requires = ["letta.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = ragIndexScript;
        StandardOutput = "append:/tmp/letta-rag.log";
        StandardError = "append:/tmp/letta-rag.log";
      };
    };

    # Watches the docs dir during a running session; re-triggers letta-rag-init
    # on any file change so newly dropped docs are indexed without a restart.
    systemd.paths.letta-rag-watch = {
      description = "Re-index docs on ~/Documents/data changes";
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      pathConfig = {
        PathChanged = cfg.rag.docsDir;
        Unit = "letta-rag-init.service";
      };
    };
  };
}
