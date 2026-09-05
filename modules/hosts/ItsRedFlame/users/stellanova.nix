{ self, ... }:
{
  flake.modules.nixos.ItsRedFlame =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.nixos.accessor ];
      security.nix-secrets.secrets.redflamepsswd.name = "ItsRedFlame/redflamepsswd";
      security.nix-secrets.secrets.stellapsswd = {
        neededForUsers = true;
        recipients = [
          "stellanova"
          host.name
        ];
      };
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
        hashedPasswordFile = config.security.nix-secrets.secrets.stellapsswd.path;
      };
      users.groups.stellanova = { };
      programs.zsh.enable = true;
    };
}
