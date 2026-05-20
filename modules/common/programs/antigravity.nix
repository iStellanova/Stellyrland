{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.antigravity.enable = lib.mkEnableOption "Antigravity";
  config = lib.mkIf config.aspects.programs.antigravity.enable {
    home-manager.users.${identity.name} = {
      home.packages = [
        (
          if isDarwin
          then pkgs.antigravity
          else pkgs.antigravity-fhs
        )
      ];
    };
  };
}
