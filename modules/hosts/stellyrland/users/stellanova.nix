{ self, lib, ... }: {
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
      programs.ssh.settings.stellyrlab = {
        HostName = lib.mkForce "172.31.255.1";
        User = "stellanova";
        IdentityFile = "/run/secrets/stellacode";
        IdentitiesOnly = "yes";
      };
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
        basics
        fastfetch
        cursor

        # Hyprland Desktop
        easyeffects
        umbriel
        noctalia
        openrgb
        hyprland
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
