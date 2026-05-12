{ identity, ... }: {
  programs.noctalia-shell.settings = {
    colorSchemes = {
      darkMode = true;
      generationMethod = "tonal-spot";
      manualSunrise = "06:30";
      manualSunset = "18:30";
      monitorForColors = "";
      predefinedScheme = "Catppuccin Lavender";
      schedulingMode = "off";
      syncGsettings = true;
      useWallpaperColors = false;
    };

    noctaliaPerformance = {
      disableDesktopWidgets = true;
      disableWallpaper = true;
    };

    templates = {
      activeTemplates = [
        {
          enabled = true;
          id = "hyprland";
        }
        {
          enabled = true;
          id = "hyprtoolkit";
        }
        {
          enabled = true;
          id = "steam";
        }
        {
          enabled = true;
          id = "zenBrowser";
        }
        {
          enabled = true;
          id = "yazi";
        }
        {
          enabled = true;
          id = "btop";
        }
        {
          enabled = true;
          id = "cava";
        }
        {
          enabled = true;
          id = "kitty";
        }
      ];
      enableUserTheming = false;
    };

    ui = {
      boxBorderEnabled = false;
      fontDefault = "Sans";
      fontDefaultScale = 1;
      fontFixed = "monospace";
      fontFixedScale = 1;
      panelBackgroundOpacity = 0.5;
      panelsAttachedToBar = true;
      scrollbarAlwaysVisible = true;
      settingsPanelMode = "window";
      settingsPanelSideBarCardStyle = false;
      tooltipsEnabled = true;
      translucentWidgets = true;
    };

    wallpaper = {
      automationEnabled = false;
      directory = "${identity.home}/Pictures/wallpapers/static";
      enableMultiMonitorDirectories = false;
      enabled = true;
      favorites = [ ];
      fillColor = "#000000";
      fillMode = "crop";
      hideWallpaperFilenames = true;
      linkLightAndDarkWallpapers = true;
      monitorDirectories = [ ];
      overviewBlur = 0.4;
      overviewEnabled = false;
      overviewTint = 0.6;
      panelPosition = "follow_bar";
      randomIntervalSec = 1800;
      setWallpaperOnAllMonitors = true;
      showHiddenFiles = true;
      skipStartupTransition = false;
      solidColor = "#1a1a2e";
      sortOrder = "random";
      transitionDuration = 1500;
      transitionEdgeSmoothness = 0.05;
      transitionType = [
        "fade"
        "disc"
        "stripes"
        "wipe"
        "pixelate"
        "honeycomb"
      ];
      useOriginalImages = false;
      useSolidColor = false;
      useWallhaven = false;
      viewMode = "recursive";
      wallhavenApiKey = "";
      wallhavenCategories = "111";
      wallhavenOrder = "desc";
      wallhavenPurity = "100";
      wallhavenQuery = "";
      wallhavenRatios = "";
      wallhavenResolutionHeight = "";
      wallhavenResolutionMode = "atleast";
      wallhavenResolutionWidth = "";
      wallhavenSorting = "relevance";
      wallpaperChangeMode = "random";
    };
  };
}
