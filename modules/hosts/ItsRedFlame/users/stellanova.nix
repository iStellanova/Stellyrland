{ self, ... }:
{
  modules.nixos.ItsRedFlame =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ self.modules.nixos.stellanova ];
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
      users.users.stellanova.hashedPasswordFile = config.security.nix-secrets.secrets.stellapsswd.path;
      users.users.stellanova.shell = pkgs.zsh;
    };
}
