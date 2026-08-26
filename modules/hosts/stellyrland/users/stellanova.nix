{ self, lib, ... }: {
  flake.modules.nixos.stellyrland = {
    imports = [ self.modules.nixos.stellanova ];

    home-manager.users.stellanova = {
      programs.ssh.settings.stellyrlab = {
        HostName = lib.mkForce "172.31.255.1";
        User = "stellanova";
        IdentityFile = "/run/secrets/stellacode";
        IdentitiesOnly = "yes";
      };

      zenBrowser.personalize = true;
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
        easyeffects
        umbriel
        noctalia
        openrgb
        hyprland
        catppuccin
        git
        nvf-ide
        nvf-writing
        opencode
        yazi
        zed
        zen-browser
        nautilus
        cava
        gsr
        media
        background-sounds
        cloud-storage
        discord
      ];
    };
  };
}
