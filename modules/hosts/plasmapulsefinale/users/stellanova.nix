{ self, ... }:
{
  flake.modules.nixos.plasmapulsefinale =
    { pkgs, ... }:
    {
      imports = [ self.modules.nixos.accessor ];
      users.users.stellanova = {
        isNormalUser = true;
        home = "/home/stellanova";
        shell = pkgs.zsh;
        group = "stellanova";
      };
      users.groups.stellanova = { };
      programs.zsh.enable = true;
    };
}
