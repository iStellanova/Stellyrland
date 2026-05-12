{ ... }: {
  programs.noctalia-shell.settings.controlCenter = {
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
}
