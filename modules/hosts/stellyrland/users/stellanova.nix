{ self, ... }: {
  flake.modules.nixos.stellyrland = {
    imports = [
      self.modules.nixos.stellanova
    ];

    home-manager.users.stellanova = {
      zenBrowser.personalize = true;

      # Actual apps installed on this host — the mime-type mapping itself
      # lives in modules/system/mime.nix.
      mimeDefaultApps = {
        browser = [ "zen-beta.desktop" ];
        pdfViewer = [ "org.gnome.Evince.desktop" ];
        fileManager = [ "org.gnome.Nautilus.desktop" ];
        imageViewer = [ "imv.desktop" ];
        musicPlayer = [ "org.gnome.Lollypop.desktop" ];
        videoPlayer = [ "mpv.desktop" ];
        discord = [ "vesktop.desktop" ];
      };

      imports = with self.modules.homeManager; [
        basics
        fastfetch

        # Hyprland Desktop
        easyeffects
        noctalia
        openrgb
        hyprland
        catppuccin

        # Dev / CLI Tools
        git
        nvf-ide
        nvf-writing
        opencode
        yazi

        # Desktop Applications
        zen-browser
        nautilus

        # AV / Media
        cava
        gsr
        media
        music
        background-sounds

        # Productivity
        cloud-storage

        # Communication
        discord
      ];
    };
  };
}
