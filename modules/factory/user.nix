{ self, ... }: {
  factory.user = username: {
    nixos."${username}" = { host, pkgs, ... }: {
      users.users."${username}".shell = pkgs.zsh;
      programs.zsh.enable = true;
      imports = [ self.modules.nixos.home-manager ];
      home-manager.users."${username}" = {
        home.username = username;
        home.homeDirectory = host.homeDir;
        programs.zsh.enable = true;
      };
    };

    darwin."${username}" = { host, pkgs, ... }: {
      users.users."${username}".shell = pkgs.zsh;
      imports = [ self.modules.darwin.home-manager ];
      home-manager.users."${username}" = {
        home.username = username;
        home.homeDirectory = host.homeDir;
        programs.zsh.enable = true;
      };
      system.primaryUser = username;
      programs.zsh.enable = true;
    };
  };
}
