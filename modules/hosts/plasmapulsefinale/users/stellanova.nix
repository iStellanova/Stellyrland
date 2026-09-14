{ self, ... }:
{
  modules.nixos.plasmapulsefinale = { pkgs, ... }: {
    imports = [ self.modules.nixos.stellanova ];
    users.users.stellanova.shell = pkgs.zsh;
  };
}
