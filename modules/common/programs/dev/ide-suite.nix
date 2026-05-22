{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.ide-suite.enable = lib.mkEnableOption "IDE suite";

  config = lib.mkIf config.aspects.programs.ide-suite.enable (lib.mkMerge [
    {
      home-manager.users.${identity.name} = {
        home.packages = with pkgs; [
          jetbrains.clion
          jetbrains.idea
          jetbrains.pycharm
        ];
      };
    }

    (lib.optionalAttrs isDarwin {
      homebrew.masApps = {
        "Xcode" = 497799835;
      };
    })
  ]);
}
