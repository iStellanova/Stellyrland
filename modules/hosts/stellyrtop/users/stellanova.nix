{ self, ... }: {
  modules.darwin.stellyrtop = {
    imports = [
      (self.factory.user "stellanova").darwin.stellanova
      self.modules.darwin.stellanova
    ];
    home-manager.users.stellanova = {
      zenBrowser.personalize = true;
      programs.ssh.settings = {
        stellyrlab = {
          HostName = "stellyrlab.tailb15b96.ts.net";
          User = "stellanova";
          IdentityFile = "/run/secrets/stellacode";
          IdentitiesOnly = "yes";
        };
        stellyrland = {
          HostName = "stellyrland.tailb15b96.ts.net";
          User = "stellanova";
          IdentityFile = "~/.ssh/stellacode";
        };
      };
      imports = with self.modules.homeManager; [
        basics
        fastfetch

        # Desktop
        omniwm
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
