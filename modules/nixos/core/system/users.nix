{
  config,
  lib,
  pkgs,
  identity,
  ...
}: {
  options.aspects.core.users.enable = lib.mkEnableOption "Core users";

  config = lib.mkIf config.aspects.core.users.enable {
    users.users.${identity.name} = {
      shell = pkgs.zsh;
      hashedPassword = identity.hashedPassword;
      isNormalUser = true;
      extraGroups = ["wheel" "storage" "disk" "video" "render" "networkmanager"];
      openssh.authorizedKeys.keys = identity.sshKeys;
    };
  };
}
