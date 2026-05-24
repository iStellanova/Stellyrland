{lib, ...}: {
  config = {
    # NixOS-only users configuration
    flake.modules.nixos.users = {
      config,
      pkgs,
      ...
    }: {
      options.aspects.core.users.enable = lib.mkEnableOption "Core users";

      config = lib.mkIf config.aspects.core.users.enable {
        users.mutableUsers = false;

        users.users.${config.identity.username} = {
          shell = pkgs.zsh;
          hashedPassword = lib.mkIf (!config.aspects.core.secrets.enable) (config.identity.hashedPassword or null);
          hashedPasswordFile = lib.mkIf config.aspects.core.secrets.enable config.sops.secrets.user-password.path;
          isNormalUser = true;
          extraGroups = ["wheel" "storage" "disk" "video" "render" "networkmanager"];
          openssh.authorizedKeys.keys = config.identity.sshKeys;
        };
      };
    };
  };
}
