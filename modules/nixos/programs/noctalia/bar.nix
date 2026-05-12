{ lib, osConfig, ... }: {
  programs.noctalia-shell.settings.bar = {
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
    monitors = [ (lib.head (lib.attrNames osConfig.aspects.core.monitors)) ];
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
          formatHorizontal = "ddd MMM d, h:mm AP";
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
}
