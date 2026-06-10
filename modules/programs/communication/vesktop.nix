_: {
  den.aspects.vesktop.nixos = {pkgs, ...}: {
    environment.systemPackages = [
      (pkgs.vesktop.override {withSystemVencord = false;})
    ];
  };

  den.aspects.vesktop.darwin = _: {
    homebrew.casks = ["vesktop"];
  };

  den.aspects.vesktop.homeManager = {pkgs, ...}: {
    xdg.configFile."vesktop/settings.json".text = builtins.toJSON {
      discordBranch = "stable";
      minimizeToTray = true;
      arRPC = true;
      splashColor = "rgb(202, 211, 245)";
      splashBackground = "rgb(24, 25, 38)";
    };

    xdg.configFile."vesktop/vencord_settings.json".text = builtins.toJSON {
      settings = {
        autoUpdate = true;
        autoUpdateNotification = true;
        useQuickCss = true;
        themeLinks = [];
        enabledThemes = [];
        plugins = {
          ChatInputButtonAPI.enabled = true;
          CommandsAPI.enabled = true;
          DynamicImageModalAPI.enabled = true;
          MessageAccessoriesAPI.enabled = true;
          MessageEventsAPI.enabled = true;
          MessagePopoverAPI.enabled = true;
          MessageUpdaterAPI.enabled = true;
          UserSettingsAPI.enabled = true;
          AccountPanelServerProfile = {
            enabled = true;
            prioritizeServerProfile = false;
          };
          AlwaysExpandRoles.enabled = true;
          AnonymiseFileNames = {
            enabled = true;
            anonymiseByDefault = true;
            method = 0;
            randomisedLength = 7;
          };
          AppleMusicRichPresence = {
            enabled = true;
            refreshInterval = 5;
            largeImageType = "Album";
            smallImageType = "Artist";
            largeTextString = "{album}";
            smallTextString = "{artist}";
            enableButtons = true;
            nameString = "Apple Music";
            detailsString = "{name}";
            stateString = "{artist} · {album}";
            activityType = 0;
            enableTimestamps = true;
            statusDisplayType = "off";
          };
          BetterGifPicker.enabled = true;
          BetterRoleContext.enabled = true;
          BetterSessions = {
            enabled = true;
            backgroundCheck = false;
          };
          CallTimer = {
            enabled = true;
            format = "stopwatch";
          };
          ClearURLs.enabled = true;
          CrashHandler.enabled = true;
          CustomRPC = {
            enabled = true;
            type = 0;
            timestampMode = 0;
          };
          FavoriteGifSearch = {
            enabled = true;
            searchOption = "hostandpath";
          };
          FixSpotifyEmbeds.enabled = true;
          FixYoutubeEmbeds.enabled = true;
          FriendsSince.enabled = true;
          GameActivityToggle = {
            enabled = true;
            oldIcon = false;
            location = "PANEL";
          };
          InvisibleChat = {
            enabled = true;
            savedPasswords = "password, Password";
          };
          MemberCount = {
            enabled = true;
            memberList = true;
            toolTip = true;
            voiceActivity = true;
          };
          MessageLogger = {
            enabled = true;
            collapseDeleted = false;
            deleteStyle = "text";
            logEdits = true;
            logDeletes = true;
            inlineEdits = true;
          };
          PreviewMessage.enabled = true;
          RelationshipNotifier = {
            enabled = true;
            offlineRemovals = true;
            groups = true;
            servers = true;
            friends = true;
            friendRequestCancels = true;
            notices = false;
          };
          ReverseImageSearch.enabled = true;
          SendTimestamps = {
            enabled = true;
            replaceMessageContents = true;
          };
          ServerInfo.enabled = true;
          ShowHiddenChannels = {
            enabled = true;
            showMode = 0;
            hideUnreads = true;
            defaultAllowedUsersAndRolesDropdownState = true;
          };
          SilentTyping = {
            enabled = true;
            isEnabled = true;
            showIcon = true;
            contextMenu = true;
          };
          Translate = {
            enabled = true;
            autoTranslate = false;
            showChatBarButton = true;
            service = "google";
            receivedInput = "auto";
            receivedOutput = "en";
            sentInput = "auto";
            sentOutput = "id";
            showAutoTranslateTooltip = true;
          };
          TypingIndicator = {
            enabled = true;
            includeMutedChannels = false;
            includeCurrentChannel = true;
            indicatorMode = 3;
            includeBlockedUsers = false;
          };
          VoiceMessages = {
            enabled = true;
            echoCancellation = true;
            noiseSuppression = true;
          };
          YoutubeAdblock.enabled = true;
          BadgeAPI.enabled = true;
          NoTrack = {
            enabled = true;
            disableAnalytics = true;
          };
          Settings = {
            enabled = true;
            settingsLocation = "aboveNitro";
            includeVencordInfoWhenCopying = true;
          };
          SupportHelper.enabled = true;
          ExpressionCloner.enabled = true;
          WebKeybinds.enabled = true;
          WebScreenShareFixes.enabled = true;
          DisableDeepLinks.enabled = true;
          WebContextMenus.enabled = true;
        };
        notifications = {
          timeout = 5000;
          position = "bottom-right";
          useNative = "not-focused";
          logLimit = 50;
        };
        cloud = {
          authenticated = true;
          url = "https://api.vencord.dev/";
          settingsSync = true;
        };
      };
      quickCss = builtins.readFile "${pkgs.catppuccin-discord.override {
        flavour = ["macchiato"];
        accents = ["sapphire"];
      }}/share/catppuccin-macchiato-sapphire.theme.css";
    };
  };
}
