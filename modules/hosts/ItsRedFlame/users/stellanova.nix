{ self, ... }:
{
  flake.modules.nixos.ItsRedFlame =
    { lib, pkgs, ... }:
    {
      imports = [ self.modules.nixos.accessor ];
      users.users.RedFlame.extraGroups = lib.mkForce [
        "networkmanager"
        "video"
        "render"
      ];
      users.users.stellanova = {
        isNormalUser = true;
        home = "/home/stellanova";
        shell = pkgs.zsh;
        group = "stellanova";
        extraGroups = [ "wheel" ];
      };
      users.groups.stellanova = { };
      programs.zsh.enable = true;
    };
}
