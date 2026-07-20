{ self, ... }: {
  flake.modules.nixos.plasmapulsefinale = {
    imports = [
      self.modules.nixos.tan13
    ];

    home-manager.users.tan13 = {
      imports = with self.modules.homeManager; [
        system-cli
        librewolf
      ];
    };
  };
}
