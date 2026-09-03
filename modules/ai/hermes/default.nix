_: {
  flake.modules.nixos.hermes =
    { config, host, ... }:
    {
      nix.settings = {
        substituters = [ "https://hermes-agent.cachix.org" ];
        trusted-public-keys = [
          "hermes-agent.cachix.org-1:jN3pjR50Mxi4SESKC/FIMNM6/LCosvPk2VUwzVvebzU="
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
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      theme = import ./_theme.nix;
    in
    {
      imports = [ inputs.hermes-agent.homeManagerModules.default ];
      programs.hermes-agent.enable = true;
      services.hermes-agent = {
        enable = true;
        gateway.enable = true;
        backend = {
          mode = "serve";
          host = "127.0.0.1";
          port = 9119;
        };
        settings = {
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
        environmentFiles = [ "/run/secrets/hermes-discord.env" ];
        extraPackages = [
          pkgs.gh
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agent-browser
          pkgs.chromium
        ];
        extraDependencyGroups = [ "messaging" ];
        extraPlugins = [
          (pkgs.runCommand "ponytail" { } ''
            cp -r ${inputs.ponytail} "$out"
          '')
        ];
        hermesHomeFiles = {
          "SOUL.md" = ''
            You are Stellxie, an intelligent personal assistant. You are quick,
            curious, direct, and attentive to detail. Help with conversation,
            research, writing, software work, and practical tasks while keeping the
            user's goals and preferences consistent across sessions.

            Communicate clearly, admit uncertainty, and prefer a concise answer unless
            more detail is useful. Treat tools and model providers as replaceable
            capabilities: your identity, memory, and relationship with the user belong
            to the Hermes framework, not to whichever model is currently active.

            You live on stellyrlab. For requested work on stellyrland, use its declared
            SSH alias and the canonical checkout at /home/stellanova/Projects/stellyrland.
            Inspect its Git status before editing and run validation there.
          '';
          "skins/${theme.name}.yaml" = builtins.toJSON theme;
        };
      };

      home.sessionVariables.SEARXNG_URL = "http://127.0.0.1:8088";
      systemd.user.sessionVariables.SEARXNG_URL = "http://127.0.0.1:8088";
      programs.ssh.settings."github-stellxie" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "/run/secrets/stellxie-github-auth";
        IdentitiesOnly = "yes";
      };
    };
}
