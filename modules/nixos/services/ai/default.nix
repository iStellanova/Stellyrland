{ config, lib, pkgs, identity, ... }:

let
  cfg = config.aspects.services.ai;
in
{
  options.aspects.services.ai.enable = lib.mkEnableOption "Local AI services (Ollama + PostgreSQL + LoRA Forge)";

  config = lib.mkIf cfg.enable {
    # 1. Ollama Service (ROCm Accelerated)
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "11.0.0"; # Necessary for RX 7900 XTX (Navi 31)
    };

    # 2. PostgreSQL Service (Memory Bank)
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = [ "ai_memory" identity.name ];
      ensureUsers = [
        {
          name = identity.name;
          ensureDBOwnership = true;
        }
      ];
    };

    # Fix for PostgreSQL 15+ public schema permissions
    systemd.services.postgresql.postStart = lib.mkAfter ''
      ${pkgs.postgresql_16}/bin/psql -d ai_memory -c "GRANT ALL ON SCHEMA public TO ${identity.name};"
    '';

    # 3. Python Environment with necessary libraries
    environment.systemPackages = with pkgs; [
      (python3.withPackages (ps: with ps; [
        requests
        psycopg2
      ]))
    ];

    # 4. Automated Data Harvesting (Systemd Timer)
    # This runs the exporter daily at 3:00 PM to prepare for training bursts.
    systemd.services.ai-data-harvest = {
      description = "Harvest AI conversation logs for LoRA training";
      serviceConfig = {
        Type = "oneshot";
        User = identity.name;
        ExecStart = "${pkgs.python3.withPackages (ps: [ ps.psycopg2 ])}/bin/python3 /home/${identity.name}/projects/local-ai/export_training_data.py";
      };
    };

    systemd.timers.ai-data-harvest = {
      description = "Daily harvest of AI data for the Personality Forge";
      timerConfig = {
        OnCalendar = "*-*-* 15:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };

    # 5. Shared Forge Directory (Permissions Bridge)
    # This directory allows both the user and the Ollama service to access the LoRA adapters.
    systemd.tmpfiles.rules = [
      "d /var/lib/echo-forge 0770 ${identity.name} ollama -"
    ];

    # 6. Dendritic Script Integration (Home Manager symlinks)
    home-manager.users.${identity.name} = {
      home.file = {
        "projects/local-ai/README.md".source = ./README.md;
        "projects/local-ai/database_manager.py".source = ./scripts/database_manager.py;
        "projects/local-ai/echo-bridge.py" = {
          source = ./scripts/echo-bridge.py;
          executable = true;
        };
        "projects/local-ai/export_training_data.py" = {
          source = ./scripts/export_training_data.py;
          executable = true;
        };
        "projects/local-ai/train_personality.py" = {
          source = ./scripts/train_personality.py;
          executable = true;
        };
        "projects/local-ai/training_shell.nix".source = ./training_shell.nix;
      };
    };
  };
}
