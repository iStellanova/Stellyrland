{ inputs, ... }:
let
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
    in
    {
      home.packages = [ upstreamPackage ];

      home.file = {
        ".hermes/SOUL.md" = {
          text = soul;
          force = true;
        };
      };

      # Use a writable config so session UI settings can still be changed.
      # A Home Manager activation reapplies the declarative baseline.
      home.activation.hermesConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.hermes"
        install -m 0600 ${configFile} "$HOME/.hermes/config.yaml"
      '';
    };
}
