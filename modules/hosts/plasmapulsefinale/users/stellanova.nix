{ self, ... }:
{
  modules.nixos.plasmapulsefinale.stellanova = { pkgs, ... }: {
    imports = [ self.modules.nixos.stellanova ];
    users.users.stellanova.shell = pkgs.zsh;
  };
}
