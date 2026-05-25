_: {
  config = {
    # NixOS IDE Suite Settings
    flake.modules.nixos.ide-suite = {lib, ...}: {
      options.aspects.programs.ide-suite.enable = lib.mkEnableOption "IDE suite";
    };

    # Darwin IDE Suite Settings
    flake.modules.darwin.ide-suite = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.ide-suite.enable = lib.mkEnableOption "IDE suite";

      config = lib.mkIf config.aspects.programs.ide-suite.enable {
        homebrew.masApps = {
          "Xcode" = 497799835;
        };
      };
    };

    # Home Manager IDE Suite Settings
    flake.modules.homeManager.ide-suite = {
      osConfig,
      pkgs,
      lib,
      ...
    }:
      lib.mkIf (osConfig ? aspects.programs.ide-suite && osConfig.aspects.programs.ide-suite.enable) {
        home.packages = with pkgs; [
          jetbrains.clion
          jetbrains.idea
          jetbrains.pycharm
        ];
      };
  };
}
