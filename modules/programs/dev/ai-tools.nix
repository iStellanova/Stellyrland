_: {
  config = {
    # NixOS AI Agent Tools
    flake.modules.nixos.ai-tools = {lib, ...}: {
      options.aspects.programs.ai-tools.enable = lib.mkEnableOption "AI Agent Tools";
    };

    # Darwin AI Agent Tools
    flake.modules.darwin.ai-tools = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.ai-tools.enable = lib.mkEnableOption "AI Agent Tools";

      config = lib.mkIf config.aspects.programs.ai-tools.enable {
        homebrew.casks = [
          "claude"
          "antigravity"
          "antigravity-cli"
        ];
      };
    };

    # Home Manager AI Agent Tools
    flake.modules.homeManager.ai-tools = {
      osConfig,
      pkgs,
      lib,
      ...
    }: let
      isDarwin = osConfig ? system.defaults;
    in
      lib.mkIf (osConfig ? aspects.programs.ai-tools && osConfig.aspects.programs.ai-tools.enable) {
        # TODO: Antigravity 2.0 dropped at I/O 2026 (May 19) — no longer a VSCode fork.
        # Includes antigravity-cli which replaces gemini-cli — swap when packaged for NixOS.
        # Neither nixpkgs (1.20.5) nor jacopone/antigravity-nix (1.23.2) track 2.0 yet (as of May 2026).
        # Switch to jacopone/antigravity-nix once it tracks 2.0, and split into desktop + CLI packages.
        home.packages = with pkgs;
          [
            claude-code
            gemini-cli
          ]
          ++ lib.optionals (!isDarwin) [antigravity-fhs];
      };
  };
}
