_: {
  config = {
    # NixOS IDE Suite Settings
    flake.modules.nixos.ide-suite = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.ide-suite.enable = lib.mkEnableOption "IDE suite";

      config = lib.mkIf config.aspects.programs.ide-suite.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = with pkgs; [
            jetbrains.clion
            jetbrains.idea
            jetbrains.pycharm
          ];
        };
      };
    };

    # Darwin IDE Suite Settings
    flake.modules.darwin.ide-suite = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.ide-suite.enable = lib.mkEnableOption "IDE suite";

      config = lib.mkIf config.aspects.programs.ide-suite.enable {
        home-manager.users.${config.identity.username} = {
          home.packages = with pkgs; [
            jetbrains.clion
            jetbrains.idea
            jetbrains.pycharm
          ];
        };

        homebrew.masApps = {
          "Xcode" = 497799835;
        };
      };
    };
  };
}
