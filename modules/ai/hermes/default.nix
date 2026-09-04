_: {
  flake.modules.nixos.hermes =
    { config, host, ... }:
    {
      nix.settings = {
        extra-substituters = [ "https://cache.numtide.com" ];
        extra-trusted-public-keys = [
          "nixs3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
      security.nix-secrets.secrets = {
        hermes-searxng-env = {
          recipients = [
            "stellanova"
            host.name
          ];
          owner = "root";
          mode = "0400";
          path = "/run/secrets/hermes-searxng.env";
        };
        hermes-discord-env = {
          recipients = [
            "stellanova"
            "stellyrlab"
            "stellyrland"
          ];
          owner = host.username;
          mode = "0400";
          path = "/run/secrets/hermes-discord.env";
        };
        stellxie-github-auth = {
          recipients = [
            "stellanova"
            "stellyrlab"
          ];
          owner = host.username;
          mode = "0600";
          path = "/run/secrets/stellxie-github-auth";
        };
        stellxie-github-signing = {
          recipients = [
            "stellanova"
            "stellyrlab"
          ];
          owner = host.username;
          mode = "0600";
          path = "/run/secrets/stellxie-github-signing";
        };
      };

      services.searx = {
        enable = true;
        domain = "localhost";
        environmentFile = config.security.nix-secrets.secrets.hermes-searxng-env.path;
        settings = {
          server = {
            bind_address = "127.0.0.1";
            port = 8088;
            secret_key = "$SEARXNG_SECRET_KEY";
          };
          search.formats = [ "json" ];
        };
      };
    };

  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };
  };

  flake.modules.homeManager.hermes =
    {
      inputs,
      pkgs,
      ...
    }:
    let
      hermesPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;
      theme = import ./_theme.nix;
      hermesConfig = {
        _config_version = 39;
        model = {
          provider = "openai-codex";
          default = "gpt-5.6-luna-900k";
        };
        fallback_providers = [
          {
            provider = "opencode-zen";
            model = "deepseek-v4-flash-free";
          }
        ];
        display = {
          interface = "tui";
          skin = theme.name;
          show_reasoning = false;
        };
        web.search_backend = "searxng";
        browser.engine = "chrome";
        platform_toolsets = {
          cli = [ "hermes-cli" ];
          discord = [ "hermes-cli" ];
        };
        database.journal_mode = "wal";
        agent.verify_on_stop = true;
        checkpoints = {
          enabled = true;
          max_snapshots = 20;
        };
        security.allow_lazy_installs = false;
        plugins.enabled = [ "ponytail" ];
        mcp_servers.nixos = {
          command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
          supports_parallel_tool_calls = true;
          sampling.enabled = false;
        };
      };
      hermesPackages = [
        hermesPackage
        pkgs.gh
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-browser
        pkgs.chromium
        pkgs.ffmpeg
        pkgs.libopus
        pkgs.python3
      ];
    in
    {
      home.packages = hermesPackages;
      home.sessionVariables = {
        SEARXNG_URL = "http://127.0.0.1:8088";
        LD_LIBRARY_PATH = "${pkgs.libopus}/lib";
      };
      systemd.user.sessionVariables = {
        SEARXNG_URL = "http://127.0.0.1:8088";
      };
      home.file = {
        ".hermes/config.yaml".text = builtins.toJSON hermesConfig;
        ".hermes/SOUL.md".text = ''
          You are Stellxie, an intelligent personal assistant. You are quick,
          curious, direct, and attentive to detail. Help with conversation,
          research, writing, software work, and practical tasks while keeping the
          user's goals and preferences consistent across sessions.

          Communicate clearly, admit uncertainty, and prefer a concise answer unless
          more detail is useful. Treat tools and model providers as replaceable
          capabilities: your identity, memory, and relationship with the user belong
          to the Hermes framework, not to whichever model is currently active.

          You live on stellyrlab.
        '';
        ".hermes/skins/${theme.name}.yaml".text = builtins.toJSON theme;
        ".hermes/plugins/ponytail" = {
          source = inputs.ponytail;
          recursive = true;
        };
      };
      systemd.user.services = {
        hermes-gateway = {
          Unit = {
            Description = "Stellxie Hermes Discord gateway";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            EnvironmentFile = "/run/secrets/hermes-discord.env";
            Environment = "LD_LIBRARY_PATH=${pkgs.libopus}/lib";
            ExecStart = "${hermesPackage}/bin/hermes gateway run";
            Restart = "always";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
        hermes-serve = {
          Unit.Description = "Stellxie Hermes remote backend";
          Service = {
            Environment = "LD_LIBRARY_PATH=${pkgs.libopus}/lib";
            ExecStart = "${hermesPackage}/bin/hermes serve --host 127.0.0.1 --port 9119";
            Restart = "always";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
      programs.ssh.settings."github-stellxie" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "/run/secrets/stellxie-github-auth";
        IdentitiesOnly = "yes";
      };
    };
}
