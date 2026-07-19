{ self, ... }: {
  flake.modules.darwin.stellyrtop = {
    imports = [
      self.modules.darwin.stellanova
    ];

    home-manager.users.stellanova = {
      # SSH alias for reaching stellyrland from this laptop over tailscale —
      # only meaningful from here, not universal like the rest of git.nix.
      programs.ssh.settings.stellyrland = {
        HostName = "stellyrland.tailb15b96.ts.net";
        User = "stellanova";
        IdentityFile = "~/.ssh/stellacode";
      };

      imports = with self.modules.homeManager; [
        # Base Desktop User Environment
        system-desktop-darwin

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
