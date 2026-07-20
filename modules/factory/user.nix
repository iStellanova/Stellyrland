{ self, ... }: {
  config.flake.factory.user = username: isAdmin: {
    nixos."${username}" =
      {
        lib,
        pkgs,
        ...
      }:
      {
        users.users."${username}" = {
          isNormalUser = true;
          home = "/home/${username}";
          extraGroups = lib.optionals isAdmin [
            "wheel"
            "networkmanager"
          ];
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
      { lib, pkgs, ... }:
      {
        users.users."${username}" = {
          name = "${username}";
          home = "/Users/${username}";
          shell = pkgs.zsh;
        };

        imports = [ self.modules.darwin.home-manager ];

        home-manager.users."${username}" = {
          imports = [
            self.modules.homeManager."${username}"
          ];
        };

        system.primaryUser = lib.mkIf isAdmin "${username}";

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
