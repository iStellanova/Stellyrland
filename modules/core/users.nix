_: {
  # NixOS users configuration
  flake.modules.nixos.users = {
    config,
    pkgs,
    lib,
    enabledAspects,
    ...
  }: {
    config = {
      users.mutableUsers = false;

      users.users.${config.identity.username} = {
        home = config.identity.homeDir;
        shell = pkgs.zsh;
        hashedPassword = lib.mkIf (!builtins.elem "secrets" enabledAspects) config.identity.hashedPassword;
        hashedPasswordFile = lib.mkIf (builtins.elem "secrets" enabledAspects) config.sops.secrets.user-password.path;
        isNormalUser = true;
        extraGroups = ["wheel" "storage" "disk" "video" "render" "networkmanager"];
        openssh.authorizedKeys.keys = config.identity.sshKeys;
      };
    };
  };

  # Darwin users configuration
  flake.modules.darwin.users = {config, ...}: {
    config = {
      users.users.${config.identity.username} = {
        name = config.identity.username;
        home = config.identity.homeDir;
      };
    };
  };
}
