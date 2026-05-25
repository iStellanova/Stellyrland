_: {
  # NixOS AI Agent Tools
  flake.modules.nixos.ai-tools = _: {
  };

  # Darwin AI Agent Tools
  flake.modules.darwin.ai-tools = _: {
    config = {
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
  in {
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
}
