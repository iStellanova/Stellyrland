_: {
  # NixOS users configuration
  flake.modules.nixos.users = {
    config,
    pkgs,
    lib,
    ...
  }: {
    config = {
      users.mutableUsers = false;

      users.users.${config.identity.username} = {
        home = config.identity.homeDir;
        shell = pkgs.zsh;
        hashedPassword = lib.mkIf (config.identity.hashedPassword != null) config.identity.hashedPassword;
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
