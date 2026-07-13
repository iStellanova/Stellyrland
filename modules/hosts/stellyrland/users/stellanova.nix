{ self, ... }: {
  flake.modules.nixos.stellyrland = {
    imports = [
      self.modules.nixos.stellanova
    ];

    home-manager.users.stellanova = {
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
