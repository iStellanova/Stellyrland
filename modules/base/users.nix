_: {
  flake.modules.nixos.users = { host, ... }: {
    users.mutableUsers = false;

    users.users.${host.username} = {
      home = host.homeDir;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "storage"
        "disk"
        "video"
        "render"
        "networkmanager"
      ];
    };
  };

  flake.modules.darwin.users = { host, ... }: {
    users.users.${host.username} = {
      name = host.username;
      home = host.homeDir;
    };
  };
}
