_: {
  flake.modules.nixos.xdg = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      xdg-user-dirs
      xdg-utils
    ];
  };

  flake.modules.homeManager.xdg =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        xdg.userDirs = {
          enable = true;
          setSessionVariables = true;
          createDirectories = true;
          documents = "${config.home.homeDirectory}/Documents";
          download = "${config.home.homeDirectory}/Downloads";
          music = "${config.home.homeDirectory}/Music";
          pictures = "${config.home.homeDirectory}/Pictures";
          videos = "${config.home.homeDirectory}/Videos";
        };

        xdg.systemDirs.data = [
          "${config.home.homeDirectory}/.local/state/nix/profiles/scratch/share"
        ];
      };
    };
}
