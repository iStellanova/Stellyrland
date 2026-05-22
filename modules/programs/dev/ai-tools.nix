{
  nixosIdentity,
  darwinIdentity,
  ...
}: {
  config = {
    # NixOS AI Agent Tools
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.ai-tools.enable = lib.mkEnableOption "AI Agent Tools";

      config = lib.mkIf config.aspects.programs.ai-tools.enable {
        home-manager.users.${nixosIdentity.name} = {
          # TODO: Antigravity 2.0 dropped at I/O 2026 (May 19) — no longer a VSCode fork.
          # Includes antigravity-cli which replaces gemini-cli — swap when packaged for NixOS.
          # Neither nixpkgs (1.20.5) nor jacopone/antigravity-nix (1.23.2) track 2.0 yet (as of May 2026).
          # Switch to jacopone/antigravity-nix once it tracks 2.0, and split into desktop + CLI packages.
          home.packages = with pkgs; [
            claude-code
            gemini-cli
            antigravity-fhs
          ];
        };
      };
    };

    # Darwin AI Agent Tools
    flake.modules.darwin.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.ai-tools.enable = lib.mkEnableOption "AI Agent Tools";

      config = lib.mkIf config.aspects.programs.ai-tools.enable {
        home-manager.users.${darwinIdentity.name} = {
          home.packages = with pkgs; [
            claude-code
            gemini-cli
          ];
        };

        homebrew.casks = [
          "claude"
          "antigravity"
          "antigravity-cli"
        ];
      };
    };
  };
}
