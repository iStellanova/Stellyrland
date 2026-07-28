{ self, ... }: {
  flake.modules.nixos.famtop = {
    imports = [
      self.modules.nixos.user1
    ];

    home-manager.users.user1 = {
      imports = with self.modules.homeManager; [
        basics
        fastfetch
        librewolf
      ];
    };
  };
}
