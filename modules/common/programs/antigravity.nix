{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  # TODO: Antigravity 2.0 dropped at I/O 2026 (May 19) — no longer a VSCode fork.
  # Switch to jacopone/antigravity-nix flake once it tracks 2.0, and split into
  # desktop IDE + CLI as separate packages. nixpkgs is still on 1.x as of May 2026.
  options.aspects.programs.antigravity.enable = lib.mkEnableOption "Antigravity";
  config = lib.mkIf config.aspects.programs.antigravity.enable {
    home-manager.users.${identity.name} = {
      home.packages = [
        (
          if isDarwin
          then pkgs.antigravity
          else pkgs.antigravity-fhs
        )
      ];
    };
  };
}
