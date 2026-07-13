{ self, ... }: {
  flake.modules.darwin.stellyrtop = {
    imports = [
      self.modules.darwin.stellanova
    ];

    home-manager.users.stellanova = {
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
