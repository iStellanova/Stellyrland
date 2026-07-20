{
  self,
  lib,
  ...
}:
{
  flake.modules = lib.mkMerge [
    (self.factory.user "tan13" true)
    {
      nixos.tan13 = {
        imports = [
          self.modules.nixos.home-manager
        ];
      };

      homeManager.tan13 =
        { host, ... }:
        {
          home.homeDirectory = host.homeDir;
          programs.zsh.enable = true;
        };
    }
  ];
}
