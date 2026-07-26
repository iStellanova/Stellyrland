{ self, ... }: {
  flake.modules.nixos.ItsRedFlame = {
    imports = [
      self.modules.nixos.RedFlame
    ];

    home-manager.users.RedFlame = {
      imports = with self.modules.homeManager; [
        # Base
        base
        cmdline

        # Desktop-Adjacent
        mime
        xdg
        kitty
        fastfetch
        librewolf
      ];
    };
  };
}
