{ self, ... }: {
  flake.modules.darwin.stellyrtop = {
    imports = [
      self.modules.darwin.stellanova
    ];

    users.users.stellanova.openssh.authorizedKeys.keys = self.constants.sshKeys ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRgqL5g6rGjR1yoD4XKOx/iHXJgYR9L6U4SU9sfOd7z stellyrlab deployment controller"
    ];

    home-manager.users.stellanova = {
      zenBrowser.personalize = true;

      # SSH alias for reaching stellyrland from this laptop over tailscale —
      # only meaningful from here, not universal like the rest of git.nix.
      programs.ssh.settings.stellyrland = {
        HostName = "stellyrland.tailb15b96.ts.net";
        User = "stellanova";
        IdentityFile = "~/.ssh/stellacode";
      };

      imports = with self.modules.homeManager; [
        basics
        fastfetch

        # Desktop
        hiro
        catppuccin

        # Dev / CLI Tools
        git
        nix-index
        nvf-writing
        ns
        opencode
        yazi

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
