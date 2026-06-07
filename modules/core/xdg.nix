_: {
  den.aspects.xdg.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      xdg-user-dirs
      xdg-utils
    ];
  };

  den.aspects.xdg.homeManager = {config, ...}: {
    xdg.userDirs = {
      enable = true;
      setSessionVariables = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      publicShare = "${config.home.homeDirectory}/Public";
      templates = "${config.home.homeDirectory}/Templates";
      videos = "${config.home.homeDirectory}/Videos";
    };

    xdg.systemDirs.data = [
      "${config.home.homeDirectory}/.local/state/nix/profiles/scratch/share"
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = let
        browser = ["zen.desktop"];
        editor = ["dev.zed.Zed.desktop"];
        pdfViewer = ["org.gnome.Evince.desktop"];
        fileManager = ["org.gnome.Nautilus.desktop"];
        imageViewer = ["imv.desktop"];
        musicPlayer = ["org.gnome.Lollypop.desktop"];
        videoPlayer = ["mpv.desktop"];
      in {
        # Browser
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

        # URL schemes
        "x-scheme-handler/discord" = ["vesktop.desktop"];

        # File manager
        "inode/directory" = fileManager;

        # Text editor
        "text/plain" = editor;
        "text/markdown" = editor;
        "text/x-script.python" = editor;
        "application/json" = editor;
        "application/x-shellscript" = editor;

        # Image viewer
        "image/jpeg" = imageViewer;
        "image/png" = imageViewer;
        "image/gif" = imageViewer;
        "image/webp" = imageViewer;
        "image/tiff" = imageViewer;
        "image/bmp" = imageViewer;
        "image/avif" = imageViewer;
        "image/svg+xml" = imageViewer;

        # Music player
        "audio/mpeg" = musicPlayer;
        "audio/flac" = musicPlayer;
        "audio/ogg" = musicPlayer;
        "audio/wav" = musicPlayer;
        "audio/x-vorbis+ogg" = musicPlayer;
        "audio/aac" = musicPlayer;
        "audio/mp4" = musicPlayer;
        "audio/x-flac" = musicPlayer;

        # PDF viewer
        "application/pdf" = pdfViewer;
        "application/x-pdf" = pdfViewer;

        # Video player
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
}
