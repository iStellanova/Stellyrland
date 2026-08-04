{ inputs, ... }:
let
  theme = import ./_theme.nix;

  hermesConfig = {
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

    display.skin = theme.name;

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
  flake.modules.homeManager.hermes =
    {
      lib,
      pkgs,
      ...
    }:
    let
      upstreamPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.hermes-agent;
      stellxiePackage = upstreamPackage.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          banner="$out/lib/python${pkgs.python3.pythonVersion}/site-packages/hermes_cli/banner.py"
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
          hermesConfig
          // {
            mcp_servers.nixos = {
              command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
              args = [ ];
              supports_parallel_tool_calls = true;
              sampling.enabled = false;
            };
          }
        )
      );
      themeFile = pkgs.writeText "${theme.name}.yaml" (builtins.toJSON theme);
    in
    {
      home.packages = [ stellxiePackage ];

      home.file = {
        ".hermes/SOUL.md" = {
          text = soul;
          force = true;
        };
      };

      # These writable files are restored to their declarative baseline on each
      # Home Manager activation, so session UI settings and skin tweaks work
      # between rebuilds without making the Nix source stop being authoritative.
      home.activation.hermesConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.hermes/skins"
        install -m 0600 ${configFile} "$HOME/.hermes/config.yaml"
        install -m 0600 ${themeFile} "$HOME/.hermes/skins/${theme.name}.yaml"
      '';
    };
}
