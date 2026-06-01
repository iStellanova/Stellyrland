{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;

  consolidatePy = pkgs.writeText "letta-consolidate.py" ''
    """
    Compact each Letta agent's in-context message history using the native
    /summarize endpoint. Runs on a timer to prevent context windows filling
    up and to keep recall memory lean. Skips agents that don't have enough
    messages to compact (< threshold).
    """
    import json, sys, urllib.request, urllib.error

    LETTA = "http://127.0.0.1:${toString cfg.letta.port}"

    def req(method, path, data=None):
        payload = json.dumps(data).encode() if data is not None else None
        r = urllib.request.Request(
            f"{LETTA}{path}",
            data=payload,
            headers={"Content-Type": "application/json"} if payload else {},
            method=method,
        )
        with urllib.request.urlopen(r, timeout=120) as resp:
            return json.load(resp)

    try:
        agents = req("GET", "/v1/agents/")
    except Exception as e:
        print(f"Could not reach Letta at {LETTA}: {e}", file=sys.stderr)
        sys.exit(1)

    if not agents:
        print("No agents found.")
        sys.exit(0)

    any_compacted = False
    for agent in agents:
        name = agent.get("name", agent["id"])
        try:
            result = req("POST", f"/v1/agents/{agent['id']}/summarize", {})
            before = result["num_messages_before"]
            after  = result["num_messages_after"]
            summary = result.get("summary", "")[:120]
            print(f"{name}: {before} → {after} messages | {summary!r}")
            any_compacted = True
        except urllib.error.HTTPError as e:
            if e.code == 400:
                # Not enough messages to compact — normal, not an error
                print(f"{name}: nothing to compact")
            else:
                body = e.read().decode(errors="replace")[:200]
                print(f"{name}: HTTP {e.code}: {body}", file=sys.stderr)
        except Exception as e:
            print(f"{name}: {e}", file=sys.stderr)

    if any_compacted:
        print("Consolidation complete.")
    else:
        print("No agents needed compaction.")
  '';

  consolidateScript = pkgs.writeShellScript "letta-consolidate" ''
    exec ${pkgs.letta}/bin/python3.11 ${consolidatePy}
  '';
in {
  config = lib.mkIf (cfg.letta.enable && cfg.consolidation.enable) {
    systemd.services.letta-consolidate = {
      description = "Letta Memory Consolidation";
      # Only run when letta is already active — don't cascade-start or fail silently
      unitConfig.ConditionUnitIsActive = "letta.service";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = consolidateScript;
      };
    };

    systemd.timers.letta-consolidate = {
      description = "Letta Memory Consolidation Timer";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = cfg.consolidation.schedule;
        # Fire on next boot if the system was off at the scheduled time
        Persistent = true;
        # Spread load across a 30-minute window to avoid competing with backups etc.
        RandomizedDelaySec = "30m";
      };
    };
  };
}
