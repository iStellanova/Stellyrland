{ self, ... }:
{
  flake.modules.nixos.stellyrlab = {
    imports = [ self.modules.nixos.stellanova ];

    home-manager.users.stellanova = {
      imports = with self.modules.homeManager; [
        base
        cmdline
        fastfetch
        git
        hermes
        nvf-ide
        deployment-distributor
        zed
      ];
    };
  };
}
