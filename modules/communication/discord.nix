{ inputs, sn, ... }: {
  sn.communication = {
    includes = [ sn.discord ];
  };

  flake-file.inputs.nixcord = {
    url = "github:4evy/nixcord";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.discord.homeManager = {
    imports = [ inputs.nixcord.homeModules.nixcord ];

    programs.nixcord = {
      enable = true;
      discord.enable = false; # Disable default discord.

      vesktop = {
        enable = true;
        # Matches the previous pkgs.vesktop.override { withSystemVencord = false; }.
        useSystemVencord = false;

        settings = {
          discordBranch = "stable";
          minimizeToTray = true;
          arRPC = true;
          splashColor = "rgb(202, 211, 245)";
          splashBackground = "rgb(24, 25, 38)";
        };
      };

      quickCss = "";

      config = {
        autoUpdate = true;
        autoUpdateNotification = true;
        useQuickCss = true;

        themeLinks = [
          "https://catppuccin.github.io/discord/dist/catppuccin-macchiato-sapphire.theme.css"
        ];
        enabledThemeLinks = [
          "https://catppuccin.github.io/discord/dist/catppuccin-macchiato-sapphire.theme.css"
        ];

        # Plugins with typed nixcord options (checked against shared.json/vencord.json/equicord.json).
        plugins = {
          accountPanelServerProfile = {
            enable = true;
            prioritizeServerProfile = false;
          };
          alwaysExpandRoles.enable = true;
          anonymiseFileNames = {
            enable = true;
            anonymiseByDefault = true;
            method = 0;
            randomisedLength = 7;
          };
          appleMusicRichPresence = {
            enable = true;
            refreshInterval = 5.0;
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
          betterGifPicker.enable = true;
          betterRoleContext.enable = true;
          betterSessions = {
            enable = true;
            backgroundCheck = false;
          };
          callTimer = {
            enable = true;
            format = "stopwatch";
          };
          clearUrls.enable = true;
          crashHandler.enable = true;
          customRpc = {
            enable = true;
            type = 0;
            timestampMode = 0;
          };
          favoriteGifSearch = {
            enable = true;
            searchOption = "hostandpath";
          };
          fixSpotifyEmbeds.enable = true;
          fixYoutubeEmbeds.enable = true;
          gameActivityToggle = {
            enable = true;
            oldIcon = false;
            location = "PANEL";
          };
          memberCount = {
            enable = true;
            memberList = true;
            toolTip = true;
            voiceActivity = true;
          };
          messageLogger = {
            enable = true;
            collapseDeleted = false;
            deleteStyle = "text";
            logEdits = true;
            logDeletes = true;
            inlineEdits = true;
          };
          previewMessage.enable = true;
          relationshipNotifier = {
            enable = true;
            offlineRemovals = true;
            groups = true;
            servers = true;
            friends = true;
            friendRequestCancels = true;
            notices = false;
          };
          reverseImageSearch.enable = true;
          sendTimestamps = {
            enable = true;
            replaceMessageContents = true;
          };
          serverInfo.enable = true;
          showHiddenChannels = {
            enable = true;
            showMode = 0;
            hideUnreads = true;
            defaultAllowedUsersAndRolesDropdownState = true;
          };
          silentTyping = {
            enable = true;
            isEnabled = true;
            showIcon = true;
            contextMenu = true;
          };
          translate = {
            enable = true;
            autoTranslate = false;
            service = "google";
            receivedInput = "auto";
            receivedOutput = "en";
            sentInput = "auto";
            sentOutput = "id";
            showAutoTranslateTooltip = true;
          };
          typingIndicator = {
            enable = true;
            includeMutedChannels = false;
            includeCurrentChannel = true;
            indicatorMode = 3;
            includeBlockedUsers = false;
          };
          voiceMessages = {
            enable = true;
            echoCancellation = true;
            noiseSuppression = true;
          };
          youtubeAdblock.enable = true;
          expressionCloner.enable = true;
          webKeybinds.enable = true;
          webScreenShareFixes.enable = true;
          disableDeepLinks.enable = true;
          webContextMenus.enable = true;
        };
      };

      # Plugins/settings nixcord has no typed option for yet: merged in as raw
      # JSON, same shape Vencord's settings.json expects directly.
      vencordConfig = {
        plugins = {
          ChatInputButtonAPI.enabled = true;
          CommandsAPI.enabled = true;
          DynamicImageModalAPI.enabled = true;
          MessageAccessoriesAPI.enabled = true;
          MessageEventsAPI.enabled = true;
          MessagePopoverAPI.enabled = true;
          MessageUpdaterAPI.enabled = true;
          UserSettingsAPI.enabled = true;
          BadgeAPI.enabled = true;
          FriendsSince.enabled = true;
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
    };
  };
}
