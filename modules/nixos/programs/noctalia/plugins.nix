{ identity, ... }: {
  programs.noctalia-shell.plugins = {
    sources = [
      {
        enabled = true;
        name = "Noctalia Plugins";
        url = "https://github.com/noctalia-dev/noctalia-plugins";
      }
    ];
    states = {
      "animated-wallpaper" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "custom-commands.backup" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "linux-wallpaperengine-controller" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "nixos-monitor" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "obs-control.backup" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "privacy-indicator.backup" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "screen-recorder.backup" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "sys-info-widget.backup" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "wallpaper-picker" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "weather-indicator.backup" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
      "zed-provider.backup" = {
        enabled = true;
        sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
      };
    };
    version = 2;
  };
  programs.noctalia-shell.pluginSettings = {
    linux-wallpaperengine-controller = {
      wallpapersFolder = "${identity.home}/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960";
      assetsDir = "${identity.home}/ExtraDisk/SteamLibrary/steamapps/common/wallpaper_engine/assets";
      iconColor = "none";
      enableExtraPropertiesEditor = true;
      defaultScaling = "fill";
      defaultClamp = "clamp";
      defaultFps = 60;
      defaultVolume = 100;
      defaultMuted = true;
      defaultAudioReactiveEffects = true;
      defaultNoAutomute = false;
      defaultDisableMouse = false;
      defaultDisableParallax = false;
      applyWallpaperColorsOnApply = false;
      wallpaperColorScreenshots = { };
      defaultNoFullscreenPause = false;
      defaultFullscreenPauseOnlyActive = true;
      autoApplyOnStartup = true;
      wallpaperScanCacheMinutes = 5;
      panelLastSelectedPath = "";
      screens = {
        "DP-3" = {
          path = "${identity.home}/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
          scaling = "fill";
        };
        "DP-2" = {
          path = "${identity.home}/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
          scaling = "fill";
        };
      };
      wallpaperProperties = {
        "818342274" = { };
        "940472387" = { };
        "1658864143" = { };
        "2402436422" = { };
        "2652493753" = { };
        "2870209872" = { };
        "2895554853" = { };
        "2912067256" = { };
        "2914109733" = { };
        "2927836891" = { };
        "2935714170" = { };
        "2967219348" = { };
        "2981249186" = { };
        "2981960200" = { };
        "2986163106" = { };
        "3020961985" = { };
        "3071278494" = { };
        "3134543499" = { };
        "3258032485" = { };
        "3293406722" = { };
        "3362507157" = { };
        "3445098742" = { };
        "3520273826" = { };
        "3555891552" = { };
        "3564471238" = { };
        "3612062318" = { };
        "3644403720" = { };
        "3652110998" = { };
        "3652156019" = { };
        "3664886661" = { };
        "3687778639" = { };
        "3689318727" = { };
        "3700017726" = { };
      };
      lastKnownGoodScreens = {
        "DP-3" = {
          path = "${identity.home}/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
          scaling = "fill";
        };
        "DP-2" = {
          path = "${identity.home}/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
          scaling = "fill";
        };
      };
      runtimeRecoveryPending = false;
    };
    "weather-indicator.backup" = {
      showTempValue = true;
      showTempUnit = true;
      showConditionIcon = true;
      tooltipOption = "everything";
      customColor = "none";
    };
    "privacy-indicator.backup" = {
      hideInactive = true;
      enableToast = true;
      removeMargins = false;
      iconSpacing = 4;
      activeColor = "none";
      inactiveColor = "none";
      micFilterRegex = "";
    };
    "obs-control.backup" = {
      pollIntervalMs = 2500;
      leftClickAction = "panel";
      launchBehavior = "minimized-to-tray";
      barLabelMode = "short-label";
      videosPath = "";
      videosOpener = "xdg-open";
      autoCloseManagedObs = true;
      openVideosAfterStop = true;
      showBarWhenRecording = true;
      showBarWhenReplay = false;
      showBarWhenStreaming = true;
      showBarWhenReady = true;
      showControlCenterWhenRecording = true;
      showControlCenterWhenReplay = true;
      showControlCenterWhenStreaming = true;
      showControlCenterWhenReady = true;
      showElapsedInBar = false;
    };
  };
}
