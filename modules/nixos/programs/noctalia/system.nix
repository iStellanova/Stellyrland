{ identity, ... }: {
  programs.noctalia-shell.settings = {
    audio = {
      mprisBlacklist = [ ];
      preferredPlayer = "";
      spectrumFrameRate = 60;
      spectrumMirrored = true;
      visualizerType = "mirrored";
      volumeFeedback = false;
      volumeFeedbackSoundFile = "";
      volumeOverdrive = false;
      volumeStep = 5;
    };

    brightness = {
      backlightDeviceMappings = [ ];
      brightnessStep = 5;
      enableDdcSupport = false;
      enforceMinimum = true;
    };

    calendar = {
      cards = [
        {
          enabled = true;
          id = "calendar-header-card";
        }
        {
          enabled = true;
          id = "calendar-month-card";
        }
        {
          enabled = true;
          id = "weather-card";
        }
      ];
    };

    desktopWidgets = {
      enabled = false;
      gridSnap = false;
      gridSnapScale = false;
      monitorWidgets = [
        {
          name = "DP-2";
          widgets = [ ];
        }
      ];
      overviewEnabled = true;
    };

    dock = {
      animationSpeed = 1;
      backgroundOpacity = 0.5;
      colorizeIcons = false;
      deadOpacity = 1;
      displayMode = "auto_hide";
      dockType = "floating";
      enabled = false;
      floatingRatio = 0.53;
      groupApps = false;
      groupClickAction = "cycle";
      groupContextMenuMode = "extended";
      groupIndicatorStyle = "dots";
      inactiveIndicators = true;
      indicatorColor = "primary";
      indicatorOpacity = 0.6;
      indicatorThickness = 3;
      launcherIcon = "";
      launcherIconColor = "none";
      launcherPosition = "start";
      launcherUseDistroLogo = true;
      monitors = [ "DP-2" ];
      onlySameOutput = false;
      pinnedApps = [
        "org.gnome.Nautilus"
        "org.prismlauncher.PrismLauncher"
        "org.nicotine_plus.Nicotine"
        "lollypop"
        "steam"
        "vesktop"
        "zen"
      ];
      pinnedStatic = true;
      position = "bottom";
      showDockIndicator = false;
      showLauncherIcon = true;
      sitOnFrame = false;
      size = 1.2;
    };

    general = {
      allowPanelsOnScreenWithoutBar = true;
      allowPasswordWithFprintd = false;
      animationDisabled = false;
      animationSpeed = 1;
      autoStartAuth = false;
      avatarImage = "${identity.home}/Pictures/PFPs/G3eRBGwWkAAJ1_v.jpg";
      boxRadiusRatio = 1;
      clockFormat = "hh\nmm";
      clockStyle = "digital";
      compactLockScreen = true;
      dimmerOpacity = 0;
      enableBlurBehind = true;
      enableLockScreenCountdown = true;
      enableLockScreenMediaControls = false;
      enableShadows = true;
      forceBlackScreenCorners = true;
      iRadiusRatio = 1;
      keybinds = {
        keyDown = [ "Down" ];
        keyEnter = [
          "Return"
          "Enter"
        ];
        keyEscape = [ "Esc" ];
        keyLeft = [ "Left" ];
        keyRemove = [ "Del" ];
        keyRight = [ "Right" ];
        keyUp = [ "Up" ];
      };
      language = "";
      lockOnSuspend = true;
      lockScreenAnimations = true;
      lockScreenBlur = 0;
      lockScreenCountdownDuration = 10000;
      lockScreenMonitors = [ "DP-2" ];
      lockScreenTint = 0;
      passwordChars = true;
      radiusRatio = 1;
      reverseScroll = false;
      scaleRatio = 1;
      screenRadiusRatio = 1;
      shadowDirection = "bottom_right";
      shadowOffsetX = 2;
      shadowOffsetY = 3;
      showChangelogOnStartup = true;
      showHibernateOnLockScreen = false;
      showScreenCorners = true;
      showSessionButtonsOnLockScreen = true;
      smoothScrollEnabled = true;
      telemetryEnabled = false;
    };

    hooks = {
      colorGeneration = "";
      darkModeChange = "";
      enabled = false;
      performanceModeDisabled = "";
      performanceModeEnabled = "";
      screenLock = "";
      screenUnlock = "";
      session = "";
      startup = "";
      wallpaperChange = "";
    };

    idle = {
      customCommands = "[]";
      enabled = true;
      fadeDuration = 5;
      lockCommand = "";
      lockTimeout = 660;
      resumeLockCommand = "";
      resumeScreenOffCommand = "";
      resumeSuspendCommand = "";
      screenOffCommand = "";
      screenOffTimeout = 66000;
      suspendCommand = "";
      suspendTimeout = 66000;
    };

    location = {
      analogClockInCalendar = false;
      autoLocate = true;
      firstDayOfWeek = -1;
      hideWeatherCityName = true;
      hideWeatherTimezone = false;
      name = "Fort Wayne";
      showCalendarEvents = true;
      showCalendarWeather = true;
      showWeekNumberInCalendar = false;
      use12hourFormat = true;
      useFahrenheit = true;
      weatherEnabled = true;
      weatherShowEffects = true;
      weatherTaliaMascotAlways = false;
    };

    network = {
      bluetoothAutoConnect = true;
      bluetoothDetailsViewMode = "grid";
      bluetoothHideUnnamedDevices = false;
      bluetoothRssiPollIntervalMs = 60000;
      bluetoothRssiPollingEnabled = false;
      disableDiscoverability = false;
      networkPanelView = "wifi";
      wifiDetailsViewMode = "list";
    };

    nightLight = {
      autoSchedule = true;
      dayTemp = "6500";
      enabled = false;
      forced = false;
      manualSunrise = "06:30";
      manualSunset = "18:30";
      nightTemp = "4000";
    };

    notifications = {
      backgroundOpacity = 0.3;
      clearDismissed = true;
      criticalUrgencyDuration = 15;
      density = "compact";
      enableBatteryToast = false;
      enableKeyboardLayoutToast = true;
      enableMarkdown = true;
      enableMediaToast = false;
      enabled = true;
      location = "top_right";
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      overlayLayer = true;
      respectExpireTimeout = false;
      saveToHistory = {
        critical = true;
        low = true;
        normal = true;
      };
      sounds = {
        criticalSoundFile = "";
        enabled = false;
        excludedApps = "discord,firefox,chrome,chromium,edge";
        lowSoundFile = "";
        normalSoundFile = "";
        separateSounds = false;
        volume = 0.5;
      };
    };

    osd = {
      autoHideMs = 2000;
      backgroundOpacity = 1;
      enabled = true;
      enabledTypes = [
        0
        1
        2
      ];
      location = "bottom";
      monitors = [ "DP-2" ];
      overlayLayer = true;
    };

    plugins = {
      autoUpdate = true;
      notifyUpdates = true;
    };

    sessionMenu = {
      countdownDuration = 10000;
      enableCountdown = true;
      largeButtonsLayout = "grid";
      largeButtonsStyle = true;
      position = "top_left";
      powerOptions = [
        {
          action = "lock";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "1";
        }
        {
          action = "suspend";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "2";
        }
        {
          action = "hibernate";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "3";
        }
        {
          action = "reboot";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "4";
        }
        {
          action = "logout";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "5";
        }
        {
          action = "shutdown";
          command = "";
          countdownEnabled = true;
          enabled = true;
          keybind = "6";
        }
        {
          action = "rebootToUefi";
          command = "";
          countdownEnabled = true;
          enabled = false;
          keybind = "";
        }
        {
          action = "userspaceReboot";
          command = "";
          countdownEnabled = true;
          enabled = false;
          keybind = "";
        }
      ];
      showHeader = true;
      showKeybinds = false;
    };

    settingsVersion = 59;

    systemMonitor = {
      batteryCriticalThreshold = 5;
      batteryWarningThreshold = 20;
      cpuCriticalThreshold = 90;
      cpuWarningThreshold = 80;
      criticalColor = "";
      diskAvailCriticalThreshold = 10;
      diskAvailWarningThreshold = 20;
      diskCriticalThreshold = 90;
      diskWarningThreshold = 80;
      enableDgpuMonitoring = true;
      externalMonitor = "resources";
      gpuCriticalThreshold = 90;
      gpuWarningThreshold = 80;
      memCriticalThreshold = 90;
      memWarningThreshold = 80;
      swapCriticalThreshold = 90;
      swapWarningThreshold = 80;
      tempCriticalThreshold = 90;
      tempWarningThreshold = 80;
      useCustomColors = false;
      warningColor = "";
    };
  };
}
