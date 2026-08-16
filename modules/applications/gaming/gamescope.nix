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
}
