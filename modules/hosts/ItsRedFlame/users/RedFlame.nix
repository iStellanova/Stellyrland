{ self, ... }: {
  modules.nixos.ItsRedFlame = {
    imports = [
      (self.factory.user "RedFlame").nixos.RedFlame
    ];

    home-manager.users.RedFlame = {
      imports = with self.modules.homeManager; [
        basics
        fastfetch
        librewolf
      ];
    };
  };
}
