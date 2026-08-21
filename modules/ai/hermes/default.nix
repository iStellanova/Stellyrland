{ inputs, ... }:
let
  theme = import ./_theme.nix;
  skills = import ./_skills.nix { inherit inputs; };
  interactiveToolsets = [
    "hermes-cli"
    "web"
    "browser"
  ];

  baseHermesConfig = {
    _config_version = 33;

    model = {
      provider = "openai-codex";
      default = "gpt-5.6-luna";
    };

    fallback_providers = [
      {
        provider = "opencode-zen";
        model = "deepseek-v4-flash-free";
      }
    ];

    display.interface = "tui";
    display.skin = theme.name;
    display.show_reasoning = false;

    web.search_backend = "searxng";
    browser.engine = "chrome";

    platform_toolsets = {
      cli = interactiveToolsets;
      discord = interactiveToolsets;
    };

    database.journal_mode = "delete";

    security.allow_lazy_installs = false;
  };

  soul = ''
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
in
{
  flake.modules.nixos.hermes =
    { config, ... }:
    {
      sops.secrets.hermes-searxng-env = {
        owner = "root";
        mode = "0400";
        path = "/run/secrets/hermes-searxng.env";
      };

      services.searx = {
        enable = true;
        domain = "localhost";
        environmentFile = config.sops.secrets.hermes-searxng-env.path;
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    proton-mcp = {
      url = "github:MrBenJ/proton-mcp";
      flake = false;
    };
  }
  // skills.flakeInputs;

  flake.modules.homeManager.hermes =
    { pkgs, ... }:
    let
      hermesPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;
      fetching = import ./_fetching.nix { inherit inputs pkgs; };
      email = import ./_email.nix { inherit inputs pkgs; };
      mcpServers =
        (baseHermesConfig.mcp_servers or { })
        // (fetching.hermesConfig.mcp_servers or { })
        // (skills.hermesConfig.mcp_servers or { })
        // (email.hermesConfig.mcp_servers or { });
      hermesConfig =
        baseHermesConfig
        // fetching.hermesConfig
        // skills.hermesConfig
        // email.hermesConfig
        // {
          mcp_servers = mcpServers;
        };
    in
    {
      home.packages = [ hermesPackage ] ++ fetching.packages ++ email.packages;

      home.sessionVariables.SEARXNG_URL = "http://127.0.0.1:8088";
      systemd.user.sessionVariables.SEARXNG_URL = "http://127.0.0.1:8088";

      home.file = {
        ".hermes/SOUL.md" = {
          text = soul;
          force = true;
        };
        ".hermes/config.yaml" = {
          text = builtins.toJSON hermesConfig;
          force = true;
        };
        ".hermes/skins/${theme.name}.yaml" = {
          text = builtins.toJSON theme;
          force = true;
        };
      }
      // skills.files
      // email.files;

      systemd.user.services = {
        hermes-gateway = {
          Unit = {
            Description = "Stellxie Hermes Discord gateway";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            EnvironmentFile = "/run/secrets/hermes-discord.env";
            ExecStart = "${hermesPackage}/bin/hermes gateway run";
            Restart = "always";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
        hermes-serve = {
          Unit.Description = "Stellxie Hermes remote backend";
          Service = {
            ExecStart = "${hermesPackage}/bin/hermes serve --host 127.0.0.1 --port 9119";
            Restart = "always";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      }
      // email.services;
    };
}
