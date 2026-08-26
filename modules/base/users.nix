{
  flake.modules.nixos.users = { host, ... }: {
    users.mutableUsers = false;

    users.users.${host.username} = {
      home = host.homeDir;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };

  flake.modules.finix.users = { host, ... }: {
    users.users.${host.username} = {
      uid = host.uid or null;
      home = host.homeDir;
      isNormalUser = true;
      extraGroups = [
        "wheel"
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
