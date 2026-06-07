_: {
  den.aspects.users.nixos = {
    host,
    pkgs,
    ...
  }: {
    users.mutableUsers = false;

    users.users.${host.username} = {
      home = host.homeDir;
      shell = pkgs.zsh;
      isNormalUser = true;
      extraGroups = ["wheel" "storage" "disk" "video" "render" "networkmanager"];
      openssh.authorizedKeys.keys = host.sshKeys;
    };
  };

  den.aspects.users.darwin = {host, ...}: {
    users.users.${host.username} = {
      name = host.username;
      home = host.homeDir;
    };
  };
}
