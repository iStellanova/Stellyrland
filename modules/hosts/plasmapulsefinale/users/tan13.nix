{ self, ... }: {
  modules.nixos.plasmapulsefinale = {
    imports = [
      (self.factory.user "tan13").nixos.tan13
    ];

    home-manager.users.tan13 = {
      imports = with self.modules.homeManager; [
        basics
        fastfetch
        librewolf
        media
      ];
    };
  };
}
