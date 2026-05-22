{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.ai-tools.enable = lib.mkEnableOption "AI Agent Tools";

  config = lib.mkIf config.aspects.programs.ai-tools.enable (lib.mkMerge [
    {
      home-manager.users.${identity.name} = {
        # TODO: Antigravity 2.0 dropped at I/O 2026 (May 19) — no longer a VSCode fork.
        # Includes antigravity-cli which replaces gemini-cli — swap when packaged for NixOS.
        # Neither nixpkgs (1.20.5) nor jacopone/antigravity-nix (1.23.2) track 2.0 yet (as of May 2026).
        # Switch to jacopone/antigravity-nix once it tracks 2.0, and split into desktop + CLI packages.
        home.packages = with pkgs;
          [
            claude-code
            gemini-cli
          ]
          ++ lib.optional (!isDarwin) antigravity-fhs;
      };
    }

    (lib.optionalAttrs isDarwin {
      homebrew.casks = [
        "claude"
        "antigravity"
        "antigravity-cli"
      ];
    })
  ]);
}
