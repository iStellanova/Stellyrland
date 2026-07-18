{ self, ... }: {
  flake.modules.nixos.onitop = {
    imports = [
      self.modules.nixos.oni
    ];

    home-manager.users.oni = {
      imports = [
        self.modules.homeManager.core
      ];
    };
  };
}
