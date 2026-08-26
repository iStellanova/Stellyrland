{ lib, ... }:
{
  flake.modules.nixos.gamescope =
    { config, ... }:
    {
      options.desktop.gaming.hdr.enable = lib.mkEnableOption "HDR support for gamescope and DXVK";

      config.programs.gamescope = {
        enable = true;
        args = [
          "--rt"
          "--fullscreen"
          "--expose-wayland"
        ]
        ++ lib.optionals config.desktop.gaming.hdr.enable [ "--hdr-enabled" ];
        env = lib.mkIf config.desktop.gaming.hdr.enable {
          "DXVK_HDR" = "1";
        };
      };
    };

  flake.modules.finix.gamescope =
    { inputs, host, pkgs, ... }:
    {
      imports = [ inputs.finix-community-modules.nixosModules.gamescope ];
      programs.gamescope = {
        enable = true;
        args = [ "--rt" "--fullscreen" "--expose-wayland" ]
          ++ lib.optionals (host.features.hdr or false) [ "--hdr-enabled" ];
        env = lib.optionalAttrs (host.features.hdr or false) { DXVK_HDR = "1"; };
      };
    };
}
