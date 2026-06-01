{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;

  # Persona for Echo: warm, conversational, actively uses memory.
  # Routing rule injected into system prompt by letta-tool-init after coder's ID is known.
  echoPersona = ''
    I am Echo, a local AI assistant with persistent memory. I know who I'm talking to
    and actively draw on past conversations. I stay light and conversational by default.
  '';

  # Persona for Coder: focused, code-first, conservative memory injection
  coderPersona = ''
    I am Coder, a code-focused AI assistant. I prioritize understanding the code in front
    of me. I reference past context only when the user explicitly asks or when it is
    directly technically relevant — otherwise I stay focused on the task at hand.
  '';

  # Persona for Core: deep reasoning, patient, thorough
  corePersona = ''
    I am Core, a deep reasoning assistant with persistent memory. I think carefully
    and thoroughly before responding. I am used for hard problems, sustained analysis,
    and situations where a quick answer is not enough.
  '';

  # Write personas to the Nix store so the shell script can cat them without
  # quoting/newline issues when embedding into Python inline code.
  echoPersonaFile = pkgs.writeText "echo-persona" echoPersona;
  coderPersonaFile = pkgs.writeText "coder-persona" coderPersona;
  corePersonaFile = pkgs.writeText "core-persona" corePersona;

  agentInitScript = pkgs.writeShellScript "letta-agent-init" ''
        LETTA="http://127.0.0.1:${toString cfg.letta.port}"
        LITELLM="http://127.0.0.1:${toString (cfg.litellm.port + 1)}"
        PY="${pkgs.python3}/bin/python3"
        CURL="${pkgs.curl}/bin/curl"

        until $CURL -sf "$LETTA/v1/health" > /dev/null 2>&1; do
          sleep 2
        done

        agent_exists() {
          local name="$1"
          $CURL -sL "$LETTA/v1/agents/?name=$name" | \
            $PY -c "import sys,json; agents=json.load(sys.stdin); exit(0 if any(a['name']=='$name' for a in agents) else 1)" 2>/dev/null
        }

        # Passes all agent fields via env vars so multiline personas survive safely.
        create_agent() {
          local name="$1" model="$2" persona_file="$3"
          if agent_exists "$name"; then
            echo "Agent $name already exists, skipping."
            return
          fi
          echo "Creating agent: $name (model: openai-proxy/$model)"
          AGENT_NAME="$name" AGENT_MODEL="$model" AGENT_HUMAN="Name: ${cfg.user}" \
            AGENT_PERSONA="$(cat "$persona_file")" \
            LETTA_URL="$LETTA" LITELLM_URL="$LITELLM" \
            $PY -c "
    import json, os, urllib.request
    payload = json.dumps({
      'name': os.environ['AGENT_NAME'],
      'agent_type': 'memgpt_agent',
      'llm_config': {
        'model': os.environ['AGENT_MODEL'],
        'model_endpoint_type': 'openai',
        'model_endpoint': os.environ['LITELLM_URL'],
        'context_window': 32768,
        'enable_reasoner': False,
      },
      'embedding_config': {
        'embedding_model': '${cfg.models.embed}',
        'embedding_endpoint_type': 'openai',
        'embedding_endpoint': os.environ['LITELLM_URL'],
        'embedding_dim': 768,
      },
      'memory_blocks': [
        {'label': 'persona', 'value': os.environ['AGENT_PERSONA']},
        {'label': 'human',   'value': os.environ['AGENT_HUMAN']},
      ],
    }).encode()
    req = urllib.request.Request(
      os.environ['LETTA_URL'] + '/v1/agents/',
      data=payload,
      headers={'Content-Type': 'application/json'},
      method='POST',
    )
    with urllib.request.urlopen(req) as r:
      a = json.load(r)
      print('Created:', a.get('name'), a.get('id', 'err'))
    " || echo "Warning: failed to create agent $name"
        }

        create_agent "echo"  "face" "${echoPersonaFile}"
        create_agent "coder" "code" "${coderPersonaFile}"
        create_agent "core"  "core" "${corePersonaFile}"
  '';
in {
  config = lib.mkIf cfg.letta.enable {
    # Create /var/lib/letta on every boot. It lives on the ephemeral @ btrfs
    # subvolume (impermanence wipes it), so StateDirectory=letta alone is not
    # enough — this runs via tmpfiles.d before any service starts.
    systemd.tmpfiles.rules = [
      "d /var/lib/letta 0750 ${cfg.user} users - -"
    ];

    # Redis — required by Letta's scheduler and background job queue
    services.redis.servers.letta = {
      enable = true;
      bind = "127.0.0.1";
      port = 6379;
    };

    systemd.services.letta = {
      description = "Letta Agent Server";
      after = ["ollama.service" "litellm.service" "litellm-think-injector.service" "qdrant.service" "redis-letta.service" "postgresql.service"];
      requires = ["ollama.service" "litellm.service" "litellm-think-injector.service" "qdrant.service" "redis-letta.service" "postgresql.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      environment = {
        # Route through think-injector (litellm.port+1) so think:false is always injected
        OPENAI_API_BASE = "http://127.0.0.1:${toString (cfg.litellm.port + 1)}/v1";
        OPENAI_API_KEY = "local-only";
        LETTA_PG_URI = "postgresql+asyncpg://${cfg.user}@localhost:5432/letta";
        LETTA_VECTOR_STORE_URI = "http://127.0.0.1:${toString cfg.qdrant.port}";
        LETTA_REDIS_HOST = "127.0.0.1";
        LETTA_TELEMETRY = "false";
      };
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        StateDirectory = "letta";
        WorkingDirectory = "/var/lib/letta";
        # Run Alembic migrations from the source tree before starting the server
        ExecStartPre = pkgs.writeShellScript "letta-db-migrate" ''
          cd ${pkgs.letta-src}
          exec ${pkgs.letta}/bin/alembic upgrade head
        '';
        ExecStart = "${pkgs.letta}/bin/letta server --host 127.0.0.1 --port ${toString cfg.letta.port}";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        StandardOutput = "append:/var/lib/letta/letta.log";
        StandardError = "append:/var/lib/letta/letta.log";
      };
    };

    # Creates echo / coder / core agents after Letta is ready. Idempotent.
    systemd.services.letta-agent-init = {
      description = "Initialize Letta Agents";
      after = ["letta.service"];
      requires = ["letta.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = agentInitScript;
        RemainAfterExit = true;
      };
    };
  };
}
