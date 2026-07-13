{
  self,
  lib,
  ...
}:
{
  flake.modules = lib.mkMerge [
    (self.factory.user "stellanova" true)
    {
      nixos.stellanova = {
        imports = [
          self.modules.nixos.home-manager
        ];
      };

      darwin.stellanova = {
        imports = [
          self.modules.darwin.home-manager
        ];
      };

      homeManager.stellanova =
        { host, ... }:
        {
          home.homeDirectory = host.homeDir;
          programs.zsh.enable = true;
        };
    }
  ];
}
