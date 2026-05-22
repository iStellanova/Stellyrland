{
  config,
  lib,
  pkgs,
  identity,
  ...
}: {
  options.aspects.programs.jetbrains.enable = lib.mkEnableOption "JetBrains IDE suite";

  config = lib.mkIf config.aspects.programs.jetbrains.enable {
    home-manager.users.${identity.name} = {
      home.packages = with pkgs; [
        jetbrains.clion
        jetbrains.idea
        jetbrains.pycharm
      ];
    };
  };
}
