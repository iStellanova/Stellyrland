{ self, ... }: {
  modules.darwin.stellyrtop.stellanova = {
    imports = [
      (self.factory.user "stellanova").darwin.stellanova
      self.modules.darwin.stellanova
    ];
    home-manager.users.stellanova = {
      zenBrowser.personalize = true;
      imports = with self.modules.homeManager; [
        stellanova
        basics
        fastfetch

        # Desktop
        catppuccin

        # Dev / CLI Tools
        git
        nvf-writing
        yazi
        zed

        # Desktop Applications
        zen-browser

        # AV / Media
        cava
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
