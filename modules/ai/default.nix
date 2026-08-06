{ inputs, ... }:
let
  theme = import ./_theme.nix;

  baseHermesConfig = {
    _config_version = 33;

    model = {
      provider = "openai-codex";
      default = "gpt-5.6-terra";
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
  '';
in
{
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.hermes =
    {
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
      discord = import ./_discord.nix { inherit stellxiePackage interactiveToolsets; };
      configFile = pkgs.writeText "hermes-config.yaml" (
        builtins.toJSON (
          (baseHermesConfig // fetching.hermesConfig)
          // {
            platform_toolsets =
              fetching.hermesConfig.platform_toolsets // discord.hermesConfig.platform_toolsets;
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
      home.packages = [ stellxiePackage ] ++ fetching.packages;

      home.sessionVariables = fetching.sessionVariables;

      home.file = {
        ".hermes/SOUL.md" = {
          text = soul;
          force = true;
        };
      }
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
        hermes-gateway = discord.service;
      };
    };
}
