{ host, ... }:
{
  desktop = {
    gaming.hdr.enable = host.features.hdr;

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
