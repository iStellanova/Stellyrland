_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      prismlauncher
    ];
  };
in
{
  flake.modules.nixos.game-launchers = {
    imports = [
      osShared
      (
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            mangohud
            goverlay
            r2modman
          ];
        }
      )
    ];
  };

  flake.modules.darwin.game-launchers = osShared;
}
