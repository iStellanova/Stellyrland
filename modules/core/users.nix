_: {
  den.aspects.users.nixos = {
    host,
    ...
  }: {
    users.mutableUsers = false;

    users.users.${host.username} = {
      home = host.homeDir;
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
