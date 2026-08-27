{ lib, ... }:
{
  options.desktop.umbriel.outputs = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = { };
    description = "Umbriel output configuration keyed by connector name.";
  };

  options.desktop.umbriel.wallpaperEngine = {
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
}
