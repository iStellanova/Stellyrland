{lib, ...}: {
  den.aspects.gaming.nixos = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.desktop.gaming;
  in {
    options.desktop.gaming.hdr.enable = lib.mkEnableOption "HDR support for gamescope and DXVK";

    config = {
      boot.kernelModules = ["ntsync"];

      programs.gamemode.enable = true;
      programs.steam = {
        enable = true;
        localNetworkGameTransfers.openFirewall = true;
        extraPackages = with pkgs; [
          libcap
          gamescope-wsi
        ];
      };
      programs.gamescope = {
        enable = true;
        args = ["--rt" "--fullscreen" "--expose-wayland"] ++ lib.optionals cfg.hdr.enable ["--hdr-enabled"];
        env = lib.mkIf cfg.hdr.enable {
          "DXVK_HDR" = "1";
          "ENABLE_GAMESCOPE_WSI" = "1";
        };
      };

      boot.kernel.sysctl = {
        "vm.max_map_count" = 2147483642;
        "kernel.nmi_watchdog" = 0;
      };

      environment.systemPackages = with pkgs; [
        mangohud
        goverlay
        heroic
        prismlauncher
        protonplus
        r2modman
      ];
    };
  };

  den.aspects.gaming.darwin = _: {
    homebrew.casks = ["steam" "prismlauncher"];
  };
}
