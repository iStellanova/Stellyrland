{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.aspects.services.ai;
in {
  options.aspects.services.ai = {
    enable = lib.mkEnableOption "Cognitive AI Architecture Stack";

    user = lib.mkOption {
      type = lib.types.str;
      default = "stellanova";
      description = "The primary user who runs and interacts with the AI stack.";
    };

    onDemand = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether the AI stack should be on-demand (disabled on startup, started manually via ai-up).";
    };

    models = {
      loadOnStartup = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to pull the Model Trinity models when Ollama starts.";
      };

      trinity = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "qwen3:8b" # L1 - Face (fast, ~5GB VRAM)
          "qwen3.6:27b" # L2 - Core / General + Deep Reasoning (thinking toggle, ~18GB VRAM)
          "devstral-small-2:24b" # L3 - Coding agent (~14GB VRAM)
        ];
        description = "List of model tags representing the 3-tier model escalation strategy.";
      };
    };

    openWebUI = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable local Open WebUI.";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "The port for Open WebUI.";
      };
    };

    oterm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the oterm client.";
      };
    };

    postgresql = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable the PostgreSQL service for Echo Memory.";
      };
      databaseName = lib.mkOption {
        type = lib.types.str;
        default = "ai_memory";
        description = "The name of the PostgreSQL database for cognitive memory.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Native Ollama Service with ROCm Acceleration on the 7900 XTX (gfx1100)
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "11.0.0"; # Automatically sets HSA_OVERRIDE_GFX_VERSION
      environmentVariables = {
        OLLAMA_MAX_LOADED_MODELS = "1"; # Explicit: one model in VRAM at a time
        OLLAMA_KEEP_ALIVE = "10m"; # Unload after 10min idle, not instantly
      };
      loadModels = lib.mkIf cfg.models.loadOnStartup cfg.models.trinity;
    };

    # Optimize Nixpkgs ROCm targeting to prevent massive compilation times
    nixpkgs.overlays = [
      (_final: prev: {
        ollama-rocm = prev.ollama-rocm.override {
          rocmPackages = prev.rocmPackages.overrideScope (_rfinal: rprev: {
            clr = rprev.clr.override {localGpuTargets = ["gfx1100"];};
          });
        };
      })
    ];

    # 2. Open WebUI (Primary GUI Station)
    services.open-webui = lib.mkIf cfg.openWebUI.enable {
      enable = true;
      port = cfg.openWebUI.port;
      environment = {
        OLLAMA_API_BASE_URL = "http://127.0.0.1:8000"; # Redirected through the memory middleware proxy
        WEBUI_AUTH = "false"; # Disable auth for secure single-user local development
      };
    };

    # 3. PostgreSQL Database (Cognitive SQL Memory)
    services.postgresql = lib.mkIf cfg.postgresql.enable {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = [cfg.postgresql.databaseName];
      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = false;
        }
      ];
      authentication = ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
    };

    # Robust oneshot initialization service running as 'postgres' admin
    systemd.services.ai-db-init = lib.mkIf cfg.postgresql.enable {
      description = "Initialize Cognitive AI Database Schema";
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        ExecStart = pkgs.writeShellScript "ai-db-init-script" ''
          PSQL="${pkgs.postgresql_16}/bin/psql -d ${cfg.postgresql.databaseName}"
          $PSQL -c "ALTER DATABASE ${cfg.postgresql.databaseName} OWNER TO ${cfg.user};"
          $PSQL -c "
            CREATE TABLE IF NOT EXISTS messages (
                id          SERIAL PRIMARY KEY,
                session_id  UUID NOT NULL,
                role        TEXT NOT NULL,
                content     TEXT NOT NULL,
                created_at  TIMESTAMPTZ DEFAULT now()
            );
            ALTER TABLE messages ADD COLUMN IF NOT EXISTS processed BOOLEAN DEFAULT FALSE;

            CREATE TABLE IF NOT EXISTS facts (
                id          SERIAL PRIMARY KEY,
                key         TEXT UNIQUE NOT NULL,
                value       TEXT NOT NULL,
                confidence  FLOAT DEFAULT 1.0,
                updated_at  TIMESTAMPTZ DEFAULT now()
            );

            CREATE TABLE IF NOT EXISTS rules (
                id          SERIAL PRIMARY KEY,
                rule        TEXT NOT NULL,
                priority    INT DEFAULT 0,
                active      BOOLEAN DEFAULT TRUE
            );

            CREATE TABLE IF NOT EXISTS traits (
                id          SERIAL PRIMARY KEY,
                trait       TEXT UNIQUE NOT NULL,
                score       FLOAT NOT NULL CHECK (score BETWEEN 0 AND 1),
                decay_rate  FLOAT DEFAULT 0.02,
                updated_at  TIMESTAMPTZ DEFAULT now()
            );
            ALTER TABLE traits ADD COLUMN IF NOT EXISTS daily_delta FLOAT DEFAULT 0.0;
            ALTER TABLE traits ADD COLUMN IF NOT EXISTS last_reset TIMESTAMPTZ DEFAULT now();
          "
        '';
        RemainAfterExit = true;
      };
    };

    # 4. Cognitive Memory Middleware Proxy (Option B: Path Co-location)
    systemd.services.echo-memory-bridge = {
      description = "Project Echo Cognitive Memory Middleware Proxy";
      after = ["postgresql.service" "ai-db-init.service" "ollama.service"];
      requires = ["postgresql.service" "ai-db-init.service" "ollama.service"];
      wantedBy =
        if cfg.onDemand
        then []
        else ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = "${pkgs.python3.withPackages (ps: [ps.fastapi ps.uvicorn ps.psycopg2 ps.httpx])}/bin/python ${./echo-bridge/main.py}";
        Restart = "on-failure";
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
      };
    };

    # 5. On-Demand / Manual Start Controls (Off by Default)
    systemd.services.ollama.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
    systemd.services.postgresql.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
    systemd.services.open-webui.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);

    # System-wide start/stop toggles
    environment.shellAliases = {
      ai-up = "sudo systemctl start ollama postgresql ai-db-init open-webui echo-memory-bridge";
      ai-down = "sudo systemctl stop ollama postgresql open-webui echo-memory-bridge";
      ai-status = "systemctl status ollama postgresql open-webui echo-memory-bridge";
    };

    # 6. System Packages (Purely Native)
    environment.systemPackages = lib.optionals cfg.oterm.enable [pkgs.oterm];

    environment.interactiveShellInit = lib.optionalString cfg.oterm.enable ''
      alias chat="OLLAMA_HOST=127.0.0.1:8000 oterm"
    '';
  };
}
