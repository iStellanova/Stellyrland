{ config, lib, ... }:

{
  options.aspects.programs.noctalia-shell.enable = lib.mkEnableOption "Noctalia shell environment";

  config = lib.mkIf config.aspects.programs.noctalia-shell.enable {
    home-manager.users.stellanova = { inputs, ... }:
      {
        imports = [
          inputs.noctalia-shell.homeModules.default
        ];

        programs.noctalia-shell = {
          enable = true;
          systemd.enable = false;
          plugins = {
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
          pluginSettings = {
            linux-wallpaperengine-controller = {
              wallpapersFolder = "/home/stellanova/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960";
              assetsDir = "/home/stellanova/ExtraDisk/SteamLibrary/steamapps/common/wallpaper_engine/assets";
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
                  path = "/home/stellanova/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
                  scaling = "fill";
                };
                "DP-2" = {
                  path = "/home/stellanova/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
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
                  path = "/home/stellanova/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
                  scaling = "fill";
                };
                "DP-2" = {
                  path = "/home/stellanova/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485";
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
          settings = {
            appLauncher = {
              autoPasteClipboard = false;
              clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
              clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
              clipboardWrapText = true;
              customLaunchPrefix = "";
              customLaunchPrefixEnabled = false;
              density = "default";
              enableClipPreview = true;
              enableClipboardChips = true;
              enableClipboardHistory = false;
              enableClipboardSmartIcons = true;
              enableSessionSearch = true;
              enableSettingsSearch = true;
              enableWindowsSearch = true;
              iconMode = "native";
              ignoreMouseInput = false;
              overviewLayer = true;
              pinnedApps = [
                "org.gnome.Lollypop"
                "zen"
                "dev.zed.Zed"
                "vesktop"
                "steam"
                "antigravity"
              ];
              position = "center";
              screenshotAnnotationTool = "";
              showCategories = true;
              showIconBackground = false;
              sortByMostUsed = true;
              terminalCommand = "kitty -e";
              viewMode = "list";
            };
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
            bar = {
              autoHideDelay = 500;
              autoShowDelay = 150;
              backgroundOpacity = 0.93;
              barType = "floating";
              capsuleColorKey = "none";
              capsuleOpacity = 0;
              contentPadding = 2;
              density = "default";
              displayMode = "always_visible";
              enableExclusionZoneInset = true;
              fontScale = 1;
              frameRadius = 12;
              frameThickness = 8;
              hideOnOverview = false;
              marginHorizontal = 12;
              marginVertical = 4;
              middleClickAction = "none";
              middleClickCommand = "";
              middleClickFollowMouse = false;
              monitors = [ "DP-2" ];
              mouseWheelAction = "none";
              mouseWheelWrap = false;
              outerCorners = true;
              position = "top";
              reverseScroll = false;
              rightClickAction = "controlCenter";
              rightClickCommand = "";
              rightClickFollowMouse = true;
              screenOverrides = [ ];
              showCapsule = true;
              showOnWorkspaceSwitch = true;
              showOutline = false;
              useSeparateOpacity = false;
              widgetSpacing = 6;
              widgets = {
                center = [
                  {
                    compactMode = true;
                    hideMode = "hidden";
                    hideWhenIdle = false;
                    id = "MediaMini";
                    maxWidth = 500;
                    panelShowAlbumArt = true;
                    scrollingMode = "hover";
                    showAlbumArt = false;
                    showArtistFirst = true;
                    showProgressRing = true;
                    showVisualizer = false;
                    textColor = "none";
                    useFixedWidth = false;
                    visualizerType = "mirrored";
                  }
                ];
                left = [
                  {
                    colorizeDistroLogo = false;
                    colorizeSystemIcon = "none";
                    colorizeSystemText = "none";
                    customIconPath = "";
                    enableColorization = true;
                    icon = "noctalia";
                    id = "ControlCenter";
                    useDistroLogo = true;
                  }
                  {
                    characterCount = 3;
                    colorizeIcons = false;
                    emptyColor = "secondary";
                    enableScrollWheel = true;
                    focusedColor = "primary";
                    followFocusedScreen = false;
                    fontWeight = "bold";
                    groupedBorderOpacity = 1;
                    hideUnoccupied = false;
                    iconScale = 0.8;
                    id = "Workspace";
                    labelMode = "none";
                    occupiedColor = "secondary";
                    pillSize = 0.68;
                    showApplications = false;
                    showApplicationsHover = false;
                    showBadge = true;
                    showLabelsOnlyWhenOccupied = true;
                    unfocusedIconsOpacity = 1;
                  }
                  {
                    colorName = "none";
                    hideWhenIdle = true;
                    id = "AudioVisualizer";
                    width = 200;
                  }
                  {
                    colorizeIcons = true;
                    hideMode = "hidden";
                    id = "ActiveWindow";
                    maxWidth = 1000;
                    scrollingMode = "hover";
                    showIcon = false;
                    showText = true;
                    textColor = "none";
                    useFixedWidth = false;
                  }
                ];
                right = [
                  {
                    blacklist = [ ];
                    chevronColor = "none";
                    colorizeIcons = true;
                    drawerEnabled = false;
                    hidePassive = false;
                    id = "Tray";
                    pinned = [ ];
                  }
                  {
                    category = "system";
                    defaultSettings = {
                      iconColor = "none";
                      showUpdatesBadge = true;
                    };
                    iconColor = "none";
                    id = "plugin:nixos-monitor";
                    showUpdatesBadge = true;
                    tags = [
                      "nixos"
                      "monitor"
                    ];
                  }
                  {
                    id = "plugin:linux-wallpaperengine-controller";
                  }
                  {
                    displayMode = "onhover";
                    iconColor = "none";
                    id = "Volume";
                    middleClickCommand = "pwvucontrol || pavucontrol";
                    textColor = "none";
                  }
                  {
                    defaultSettings = {
                      activeColor = "primary";
                      enableToast = true;
                      hideInactive = false;
                      iconSpacing = 4;
                      inactiveColor = "none";
                      micFilterRegex = "";
                      removeMargins = false;
                    };
                    id = "plugin:privacy-indicator.backup";
                  }
                  {
                    defaultSettings = {
                      customColor = "none";
                      showConditionIcon = true;
                      showTempUnit = true;
                      showTempValue = true;
                      tooltipOption = "everything";
                    };
                    id = "plugin:weather-indicator.backup";
                  }
                  {
                    compactMode = false;
                    diskPath = "/";
                    iconColor = "none";
                    id = "SystemMonitor";
                    showCpuCores = false;
                    showCpuFreq = false;
                    showCpuTemp = true;
                    showCpuUsage = true;
                    showDiskAvailable = false;
                    showDiskUsage = false;
                    showDiskUsageAsPercent = false;
                    showGpuTemp = true;
                    showLoadAverage = false;
                    showMemoryAsPercent = false;
                    showMemoryUsage = true;
                    showNetworkStats = true;
                    showSwapUsage = false;
                    textColor = "none";
                    useMonospaceFont = true;
                    usePadding = false;
                  }
                  {
                    clockColor = "none";
                    customFont = "";
                    formatHorizontal = "h:mm AP";
                    formatVertical = "HH mm - dd MM";
                    id = "Clock";
                    tooltipFormat = "HH:mm ddd, MMM dd";
                    useCustomFont = false;
                  }
                  {
                    hideWhenZero = false;
                    hideWhenZeroUnread = false;
                    iconColor = "none";
                    id = "NotificationHistory";
                    showUnreadBadge = true;
                    unreadBadgeColor = "primary";
                  }
                ];
              };
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
            controlCenter = {
              cards = [
                {
                  enabled = true;
                  id = "profile-card";
                }
                {
                  enabled = true;
                  id = "shortcuts-card";
                }
                {
                  enabled = true;
                  id = "audio-card";
                }
                {
                  enabled = false;
                  id = "brightness-card";
                }
                {
                  enabled = true;
                  id = "weather-card";
                }
                {
                  enabled = true;
                  id = "media-sysmon-card";
                }
              ];
              diskPath = "/";
              position = "close_to_bar_button";
              shortcuts = {
                left = [
                  {
                    id = "Network";
                  }
                  {
                    id = "WallpaperSelector";
                  }
                  {
                    defaultSettings = {
                      audioCodec = "opus";
                      audioSource = "default_output";
                      colorRange = "limited";
                      copyToClipboard = false;
                      customReplayDuration = "30";
                      directory = "";
                      filenamePattern = "recording_yyyyMMdd_HHmmss";
                      frameRate = "60";
                      hideInactive = false;
                      iconColor = "none";
                      quality = "very_high";
                      replayDuration = "30";
                      replayEnabled = false;
                      replayStorage = "ram";
                      resolution = "original";
                      restorePortalSession = false;
                      showCursor = true;
                      videoCodec = "h264";
                      videoSource = "portal";
                    };
                    id = "plugin:screen-recorder.backup";
                  }
                  {
                    id = "plugin:linux-wallpaperengine-controller";
                  }
                ];
                right = [
                  {
                    id = "KeepAwake";
                  }
                  {
                    id = "NightLight";
                  }
                  {
                    defaultSettings = {
                      autoCloseManagedObs = true;
                      barLabelMode = "short-label";
                      launchBehavior = "minimized-to-tray";
                      leftClickAction = "panel";
                      openVideosAfterStop = true;
                      pollIntervalMs = 2500;
                      showBarWhenReady = true;
                      showBarWhenRecording = true;
                      showBarWhenReplay = false;
                      showBarWhenStreaming = true;
                      showControlCenterWhenReady = false;
                      showControlCenterWhenRecording = true;
                      showControlCenterWhenReplay = true;
                      showControlCenterWhenStreaming = true;
                      showElapsedInBar = false;
                      videosOpener = "xdg-open";
                      videosPath = "";
                    };
                    id = "plugin:obs-control.backup";
                  }
                ];
              };
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
              enabled = true;
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
              avatarImage = "/home/stellanova/Pictures/PFPs/G3eRBGwWkAAJ1_v.jpg";
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
            noctaliaPerformance = {
              disableDesktopWidgets = true;
              disableWallpaper = true;
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
              monitors = [ "DP-2" ];
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
              directory = "/home/stellanova/Pictures/wallpapers/static";
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
        };

        # Link ONLY the nixos-monitor plugin so it is available to Noctalia.
        # We use force = true to ensure it overwrites any existing local version
        # with the one from the flake.
        xdg.configFile."noctalia/plugins/nixos-monitor" = {
          source = inputs.noctalia-nix-monitor;
          force = true;
        };
      };
  };
}
