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

    terminal = {
      backend = "local";
      home_mode = "auto";
      timeout = 180;
    };

    display = {
      interface = "tui";
      skin = theme.name;
      show_reasoning = false;
      show_cost = false;
    };

    approvals = {
      mode = "smart";
      timeout = 300;
    };

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
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      interactiveToolsets = [
        "hermes-cli"
        "web"
        "browser"
      ];
      upstreamPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;
      fetching = import ./_fetching.nix { inherit pkgs interactiveToolsets; };
      searxngPluginManifest = pkgs.writeText "hermes-web-searxng-plugin.yaml" ''
        name: web-searxng
        version: 1.0.0
        description: "SearXNG web search — free, self-hosted, privacy-respecting metasearch engine. Requires SEARXNG_URL pointing at your instance."
        author: NousResearch
        kind: backend
        provides_web_providers:
          - searxng
      '';
      stellxiePackage = upstreamPackage.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          package_root="$out/lib/python${pkgs.python3.pythonVersion}/site-packages"
          banner="$package_root/hermes_cli/banner.py"
          # Restore bundled discovery metadata and the Discord platform adapter.
          install -Dm644 \
            ${searxngPluginManifest} \
            "$package_root/plugins/web/searxng/plugin.yaml"
          cp -r \
            ${old.src}/plugins/platforms/discord \
            "$package_root/plugins/platforms/"
          substituteInPlace "$banner" \
            --replace-fail \
              "base = f\"Hermes Agent v{VERSION} ({RELEASE_DATE})\"" \
              "base = f\"Stellxie v{VERSION} ({RELEASE_DATE})\"" \
            --replace-fail \
              'colored_names.append(f"[yellow]{name}[/]")' \
              "colored_names.append(f\"[{_skin_color('ui_accent', '#8aadf4')}]{name}[/]\")"
        '';
      });
      configFile = pkgs.writeText "hermes-config.yaml" (
        builtins.toJSON (
          (baseHermesConfig // fetching.hermesConfig // skills.hermesConfig)
          // {
            platform_toolsets = fetching.hermesConfig.platform_toolsets // {
              discord = interactiveToolsets;
            };
            mcp_servers = fetching.hermesConfig.mcp_servers // {
              nixos = {
                command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
                args = [ ];
                supports_parallel_tool_calls = true;
                sampling.enabled = false;
              };
            };
          }
        )
      );
      themeFile = pkgs.writeText "${theme.name}.yaml" (builtins.toJSON theme);
    in
    {
      options.services.hermes-serve.enable = lib.mkEnableOption "the local Stellxie remote backend";

      config = {
        home.packages = [ stellxiePackage ] ++ fetching.packages;

        home.sessionVariables = fetching.sessionVariables;

        home.file = {
          ".hermes/SOUL.md" = {
            text = soul;
            force = true;
          };
        }
        // skills.files
        // fetching.files;

        # Keep the managed baseline authoritative on each Home Manager activation.
        home.activation = {
          hermesFetching = lib.hm.dag.entryAfter [ "writeBoundary" ] fetching.activation;
          hermesConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p "$HOME/.hermes/skins"
            install -m 0600 ${configFile} "$HOME/.hermes/config.yaml"
            install -m 0600 ${themeFile} "$HOME/.hermes/skins/${theme.name}.yaml"
          '';
        };

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
              ExecStart = "${stellxiePackage}/bin/hermes gateway run";
              Restart = "always";
              RestartSec = 5;
            };
            Install.WantedBy = [ "default.target" ];
          };
          hermes-serve = lib.mkIf config.services.hermes-serve.enable {
            Unit.Description = "Stellxie Hermes remote backend";
            Service = {
              # ponytail: SSH forwarding is the access boundary; add public auth only when needed.
              ExecStart = "${stellxiePackage}/bin/hermes serve --host 127.0.0.1 --port 9119";
              Restart = "always";
              RestartSec = 5;
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
      };
    };
}
