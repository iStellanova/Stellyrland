{ self, ... }: {
  flake.modules.darwin.stellyrtop = {
    imports = [
      self.modules.darwin.stellanova
    ];

    home-manager.users.stellanova = {
      zenBrowser.personalize = true;

      # Host-specific Tailscale route; shared SSH defaults live in git.nix.
      programs.ssh.settings.stellyrland = {
        HostName = "stellyrland.tailb15b96.ts.net";
        User = "stellanova";
        IdentityFile = "~/.ssh/stellacode";
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
        opencode
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
