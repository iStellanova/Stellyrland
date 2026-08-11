{ inputs, ... }:
{
  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.opencode =
    { pkgs, ... }:
    {
      programs.mcp = {
        enable = true;
        # Full store path, not the bare "mcp-nixos" name on $PATH.
        servers.mcp-nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };

      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        # Uses opencode package from llm-agents. Properly packaged with patches.
        # Supposedly nixpkgs and the official flake have issues on nixos.
        package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

        # External Models.
        settings.plugin = [
          "opencode-claude-auth@latest"
          "opencode-antigravity-auth@latest"
        ];

        themes.catppuccin-macchiato-transparent = import ./_opencode-theme.nix;
        tui.theme = "catppuccin-macchiato-transparent";
      };
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
