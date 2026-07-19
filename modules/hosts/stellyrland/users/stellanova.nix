{ self, ... }: {
  flake.modules.nixos.stellyrland = {
    imports = [
      self.modules.nixos.stellanova
    ];

    home-manager.users.stellanova = {
      # Actual apps installed on this host — the mime-type mapping itself
      # lives in modules/system/mime.nix.
      mimeDefaultApps = {
        browser = [ "zen.desktop" ];
        editor = [ "dev.zed.Zed.desktop" ];
        pdfViewer = [ "org.gnome.Evince.desktop" ];
        fileManager = [ "org.gnome.Nautilus.desktop" ];
        imageViewer = [ "imv.desktop" ];
        musicPlayer = [ "org.gnome.Lollypop.desktop" ];
        videoPlayer = [ "mpv.desktop" ];
        discord = [ "vesktop.desktop" ];
      };

      imports = with self.modules.homeManager; [
        # Base Desktop User Environment
        system-desktop-nixos

        # Dev / CLI Tools
        git
        helix
        nix-index
        ns
        yazi
        zed

        # Desktop Applications
        zen-browser
        nautilus

        # AV / Media
        cava
        gsr
        sidra
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
