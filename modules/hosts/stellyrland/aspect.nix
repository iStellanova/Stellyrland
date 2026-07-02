{
  den,
  sn,
  ...
}:
{
  den.aspects.stellyrland = {
    includes = [
      sn.nix-base
      den.batteries.hostname
      sn.system
      sn.linux-boot
      sn.linux-hardware
      sn.linux-storage
      sn.terminal
      sn.dev
      sn.desktop
      sn.communication
      sn.av
      sn.gaming
      sn.openrgb
      sn.email
      sn.cloud-storage
    ];

    nixos = { host, ... }: {
      imports = [ ./_hardware-configuration.nix ];

      core.boot.secureBoot = host.features.secureBoot;
      core.headless.disabledPorts = [
        "DP-2"
        "DP-3"
      ];
      core.nix-settings.cores = 24;

      desktop.gaming.hdr.enable = host.features.hdr;

      desktop.hyprland.wallpaperEngine.steamLibrary = "/ExtraDisk";
      desktop.hyprland.wallpaperEngine.workshopId = "3258032485";
      desktop.hyprland.wallpaperEngine.screenRoots = [
        "DP-2"
        "DP-3"
      ];
      desktop.hyprland.hyprsplit.monitorPriority = [
        "DP-2"
        "DP-3"
      ];

      desktop.noctalia.primaryMonitor = "DP-2";
      desktop.noctalia.secondaryMonitor = "DP-3";

      desktop.hyprland.monitors = [
        {
          output = "DP-2";
          mode = "3440x1440@175";
          position = "1440x541";
          scale = 1;
          bitdepth = 10;
          cm = "hdr";
          supports_wide_color = 1;
          sdr_min_luminance = 0.0;
          sdr_max_luminance = 203;
          sdrbrightness = 0.75;
          sdrsaturation = 1.2;
          min_luminance = 0.0005;
          max_luminance = 1000;
          max_avg_luminance = 250;
        }
        {
          output = "DP-3";
          mode = "2560x1440@100";
          position = "0x0";
          scale = 1;
          transform = 1;
          bitdepth = 10;
          cm = "srgb";
          sdr_min_luminance = 0.2;
          min_luminance = 0.25;
          max_luminance = 250;
          max_avg_luminance = 250;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];
    };
  };
}
