_: {
  flake.modules.nixos.stellyrland-host =
    { host, lib, ... }:
    {
      imports = [ ./_hardware-configuration.nix ];

      networking.hostName = host.name;

      core = {
        boot.secureBoot = true;
        headless.disabledPorts = host.monitorPriority;
        nix-settings.cores = 24;
        impermanence = true;
      };

      desktop = {
        gaming.hdr.enable = host.features.hdr;

        hyprland = {
          wallpaperEngine = {
            steamLibrary = "/ExtraDisk";
            workshopId = "3258032485";
            screenRoots = host.monitorPriority;
          };

          hyprsplit = {
            inherit (host) monitorPriority;
            numWorkspaces = 7;
          };

          monitors = [
            {
              output = lib.elemAt host.monitorPriority 0;
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
              output = lib.elemAt host.monitorPriority 1;
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
    };
}
