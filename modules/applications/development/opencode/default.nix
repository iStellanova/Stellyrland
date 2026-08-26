{ inputs, ... }:
{
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.opencode =
    { osConfig, pkgs, ... }:
    {
      programs.mcp = {
        enable = true;
        # Full store path, not the bare "mcp-nixos" name on $PATH.
        servers.mcp-nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };

      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        # The nixpkgs and upstream packages fail on NixOS; use llm-agents.
        package = osConfig._module.args.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

        settings.plugin = [
          "opencode-claude-auth@latest"
          "opencode-antigravity-auth@latest"
        ];

        themes.catppuccin-macchiato-transparent = import ./_opencode-theme.nix;
        tui.theme = "catppuccin-macchiato-transparent";
      };
    };

  flake.modules.finix.opencode =
    { host, ... }:
    {
      preservation.preserveAt."/persist".users.${host.username}.directories = [
        ".config/opencode"
        ".local/share/opencode"
      ];
    };

  flake.modules.nixos.opencode =
    { lib, host, ... }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".config/opencode"
          ".local/share/opencode"
        ];
      };
    };
}
