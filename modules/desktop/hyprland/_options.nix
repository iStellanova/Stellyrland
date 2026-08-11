{ lib, ... }:
{
  options.desktop.hyprland = {
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];
      description = "Monitor configurations passed to hl.monitor().";
    };
    wallpaperEngine = {
      steamLibrary = lib.mkOption {
        type = lib.types.str;
        default = "/ExtraDisk/SteamLibrary";
        description = "Path to the Steam library containing wallpaper_engine and workshop content.";
      };
      workshopId = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Workshop item ID to pass to linux-wallpaperengine. Empty disables it.";
      };
      screenRoots = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "List of monitor outputs to pass as --screen-root flags to linux-wallpaperengine.";
      };
    };
    hyprsplit = {
      monitorPriority = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Monitor output names in priority order for hyprsplit workspace assignment. Empty omits the priority call.";
      };
      numWorkspaces = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "Number of workspaces hyprsplit creates per monitor.";
      };
    };
  };
}
