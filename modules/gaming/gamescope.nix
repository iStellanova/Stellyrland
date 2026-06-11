{
  sn,
  lib,
  ...
}: {
  sn.gaming = {includes = [sn.gamescope];};

  sn.gamescope.nixos = {config, ...}: let
    cfg = config.desktop.gaming;
  in {
    options.desktop.gaming.hdr.enable = lib.mkEnableOption "HDR support for gamescope and DXVK";

    config.programs.gamescope = {
      enable = true;
      args = ["--rt" "--fullscreen" "--expose-wayland"] ++ lib.optionals cfg.hdr.enable ["--hdr-enabled"];
      env = lib.mkIf cfg.hdr.enable {
        "DXVK_HDR" = "1";
        "ENABLE_GAMESCOPE_WSI" = "1";
      };
    };
  };
}
