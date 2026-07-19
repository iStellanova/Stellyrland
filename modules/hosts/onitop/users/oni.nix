{ self, ... }: {
  flake.modules.nixos.onitop = {
    imports = [
      self.modules.nixos.oni
    ];

    home-manager.users.oni = {
      imports = with self.modules.homeManager; [
        system-cli
        librewolf
      ];
    };
  };
}
