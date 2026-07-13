_: {
  flake.modules.nixos.mime = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xdg-utils ];
  };

  flake.modules.homeManager.mime =
    {
      pkgs,
      lib,
      ...
    }:
    {
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        xdg.mimeApps = {
          enable = true;
          defaultApplications =
            let
              browser = [ "zen.desktop" ];
              editor = [ "dev.zed.Zed.desktop" ];
              pdfViewer = [ "org.gnome.Evince.desktop" ];
              fileManager = [ "org.gnome.Nautilus.desktop" ];
              imageViewer = [ "imv.desktop" ];
              musicPlayer = [ "org.gnome.Lollypop.desktop" ];
              videoPlayer = [ "mpv.desktop" ];
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

              "x-scheme-handler/discord" = [ "vesktop.desktop" ];

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
