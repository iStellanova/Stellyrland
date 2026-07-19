_: {
  flake.modules.nixos.mime = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xdg-utils ];
  };

  flake.modules.homeManager.mime =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # Category -> .desktop file(s) actually installed on this host. The
      # mime-type mapping below is universal; only these bindings vary.
      options.mimeDefaultApps = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
      };

      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        xdg.mimeApps = {
          enable = true;
          defaultApplications =
            let
              apps = config.mimeDefaultApps;
              browser = apps.browser or [ ];
              editor = apps.editor or [ ];
              pdfViewer = apps.pdfViewer or [ ];
              fileManager = apps.fileManager or [ ];
              imageViewer = apps.imageViewer or [ ];
              musicPlayer = apps.musicPlayer or [ ];
              videoPlayer = apps.videoPlayer or [ ];
              discordApp = apps.discord or [ ];
            in
            {
              "x-scheme-handler/http" = browser;
              "x-scheme-handler/https" = browser;
              "x-scheme-handler/chrome" = browser;
              "text/html" = browser;
              "application/x-extension-htm" = browser;
              "application/x-extension-html" = browser;
              "application/x-extension-shtml" = browser;
              "application/xhtml+xml" = browser;
              "application/x-extension-xhtml" = browser;
              "application/x-extension-xht" = browser;

              "x-scheme-handler/discord" = discordApp;

              "inode/directory" = fileManager;

              "text/plain" = editor;
              "text/markdown" = editor;
              "text/x-script.python" = editor;
              "application/json" = editor;
              "application/x-shellscript" = editor;

              "image/jpeg" = imageViewer;
              "image/png" = imageViewer;
              "image/gif" = imageViewer;
              "image/webp" = imageViewer;
              "image/tiff" = imageViewer;
              "image/bmp" = imageViewer;
              "image/avif" = imageViewer;
              "image/svg+xml" = imageViewer;

              "audio/mpeg" = musicPlayer;
              "audio/flac" = musicPlayer;
              "audio/ogg" = musicPlayer;
              "audio/wav" = musicPlayer;
              "audio/x-vorbis+ogg" = musicPlayer;
              "audio/aac" = musicPlayer;
              "audio/mp4" = musicPlayer;
              "audio/x-flac" = musicPlayer;

              "application/pdf" = pdfViewer;
              "application/x-pdf" = pdfViewer;

              "video/mp4" = videoPlayer;
              "video/x-matroska" = videoPlayer;
              "video/webm" = videoPlayer;
              "video/avi" = videoPlayer;
              "video/quicktime" = videoPlayer;
              "video/x-msvideo" = videoPlayer;
              "video/mpeg" = videoPlayer;
            };
        };
      };
    };
}
