{ self, ... }: {
  config.flake.factory.user = username: {
    nixos."${username}" =
      {
        pkgs,
        ...
      }:
      {
        users.users."${username}" = {
          shell = pkgs.zsh;
        };
        programs.zsh.enable = true;

        imports = [ self.modules.nixos.home-manager ];

        home-manager.users."${username}" = {
          imports = [
            self.modules.homeManager."${username}"
          ];
        };
      };

    darwin."${username}" =
      { pkgs, ... }:
      {
        users.users."${username}" = {
          shell = pkgs.zsh;
        };

        imports = [ self.modules.darwin.home-manager ];

        home-manager.users."${username}" = {
          imports = [
            self.modules.homeManager."${username}"
          ];
        };

        system.primaryUser = username;

        programs.zsh.enable = true;
      };

    homeManager."${username}" =
      { host, ... }:
      {
        home.username = "${username}";
        home.homeDirectory = host.homeDir;
        programs.zsh.enable = true;
      };
  };
}
