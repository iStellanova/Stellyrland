{
  self,
  lib,
  ...
}:
{
  flake.modules = lib.mkMerge [
    (self.factory.user "oni" true)
    {
      nixos.oni = {
        imports = [
          self.modules.nixos.home-manager
        ];
      };

      homeManager.oni =
        { host, ... }:
        {
          home.homeDirectory = host.homeDir;
          programs.zsh.enable = true;
        };
    }
  ];
}
