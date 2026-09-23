{ self, ... }: {
  modules.nixos.stellyrland.stellanova = {
    imports = [
      (self.factory.user "stellanova").nixos.stellanova
      self.modules.nixos.stellanova
    ];
    security.nix-secrets.secrets.stellacode = {
      recipients = [
        "stellanova"
        "stellyrland"
      ];
      owner = "stellanova";
      mode = "0600";
      path = "/run/secrets/stellacode";
    };
    home-manager.users.stellanova = {
      zenBrowser.personalize = true;
      # Installed desktop files; MIME types are defined in modules/system/mime.nix.
      mimeDefaultApps = {
        browser = [ "zen-beta.desktop" ];
        pdfViewer = [ "org.gnome.Evince.desktop" ];
        fileManager = [ "org.gnome.Nautilus.desktop" ];
        imageViewer = [ "imv.desktop" ];
        musicPlayer = [ "mpv.desktop" ];
        videoPlayer = [ "mpv.desktop" ];
        discord = [ "vesktop.desktop" ];
      };
      imports = with self.modules.homeManager; [
        stellanova
        basics
        fastfetch
        cursor

        # Umbriel Desktop
        easyeffects
        umbriel
        noctalia
        openrgb
        catppuccin

        # Dev / CLI Tools
        git
        nvf-ide
        nvf-writing
        yazi
        zed

        # Desktop Applications
        zen-browser
        nautilus

        # AV / Media
        cava
        gsr
        media
        background-sounds

        # Productivity
        cloud-storage

        # Communication
        discord
      ];
    };
  };
}
