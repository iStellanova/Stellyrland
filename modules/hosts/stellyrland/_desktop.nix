{ host, lib, ... }:
{
  desktop = {
    gaming.hdr.enable = host.features.hdr;

    hyprland = {
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

    umbriel = {
      wallpaperEngine = {
        steamLibrary = "/ExtraDisk";
        workshopId = "3258032485";
        screenRoots = host.monitorPriority;
      };

      outputs = {
        "DP-2" = {
          mode = "3440x1440@175";
          position = [
            1440
            541
          ];
          scale = 1;
          hdr = "on";
          sdr_white = 203;
          workspaces = 7;
        };
        "DP-3" = {
          mode = "2560x1440@100";
          position = [
            0
            0
          ];
          scale = 1;
          hdr = "auto";
          transform = "90";
          workspaces = 7;
        };
      };
    };
  };
}
