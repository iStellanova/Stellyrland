{
  nixosIdentity,
  darwinIdentity,
  ...
}: {
  config = {
    # NixOS IDE Suite Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.ide-suite.enable = lib.mkEnableOption "IDE suite";

      config = lib.mkIf config.aspects.programs.ide-suite.enable {
        home-manager.users.${nixosIdentity.name} = {
          home.packages = with pkgs; [
            jetbrains.clion
            jetbrains.idea
            jetbrains.pycharm
          ];
        };
      };
    };

    # Darwin IDE Suite Settings
    flake.modules.darwin.default = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.ide-suite.enable = lib.mkEnableOption "IDE suite";

      config = lib.mkIf config.aspects.programs.ide-suite.enable {
        home-manager.users.${darwinIdentity.name} = {
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
