{ inputs, ... }:
let
  theme = import ./_theme.nix;
  skills = import ./_skills.nix { inherit inputs; };

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

    # A single interactive process does not need WAL concurrency, and the
    # rollback host stores home on ZFS where SQLite WAL is less robust.
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
  flake-file.inputs = {
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  }
  // skills.flakeInputs;

  flake.modules.homeManager.hermes =
    { pkgs, ... }:
    let
      interactiveToolsets = [
        "hermes-cli"
        "web"
        "browser"
      ];
      # TODO: remove this override once llm-agents.nix packages an upstream
      # Hermes release that includes registration_lifecycle in py-modules.
      hermesPackage =
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent.overrideAttrs
          (old: {
            postPatch = (old.postPatch or "") + ''
              sed -i '/^  "run_agent",$/a\  "registration_lifecycle",' pyproject.toml
            '';
          });
      fetching = import ./_fetching.nix { inherit pkgs interactiveToolsets; };
    in
    {
      home.packages = [ hermesPackage ] ++ fetching.packages;

      home.sessionVariables = fetching.sessionVariables;
      systemd.user.sessionVariables = fetching.sessionVariables;

      home.file = {
        ".hermes/SOUL.md" = {
          text = soul;
          force = true;
        };
        ".hermes/config.yaml" = {
          text = builtins.toJSON (
            (baseHermesConfig // fetching.hermesConfig // skills.hermesConfig)
            // {
              platform_toolsets = fetching.hermesConfig.platform_toolsets // {
                discord = interactiveToolsets;
              };
              mcp_servers = fetching.hermesConfig.mcp_servers // {
                nixos = {
                  command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
                  supports_parallel_tool_calls = true;
                  sampling.enabled = false;
                };
              };
            }
          );
          force = true;
        };
        ".hermes/skins/${theme.name}.yaml" = {
          text = builtins.toJSON theme;
          force = true;
        };
      }
      // skills.files;

      systemd.user.services = {
        hermes-searxng = fetching.searxngService;
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
            # ponytail: SSH forwarding is the access boundary; add public auth only when needed.
            ExecStart = "${hermesPackage}/bin/hermes serve --host 127.0.0.1 --port 9119";
            Restart = "always";
            RestartSec = 5;
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
}
