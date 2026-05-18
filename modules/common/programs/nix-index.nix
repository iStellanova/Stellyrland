{
  config,
  lib,
  pkgs,
  identity,
  ...
}: {
  options.aspects.programs.nix-index.enable = lib.mkEnableOption "nix-index with pre-built database and comma";

  config = lib.mkIf config.aspects.programs.nix-index.enable {
    home-manager.users.${identity.name} = {
      programs.nix-index = {
        enable = true;
        enableNixLocate = true;
      };
      home.packages = [pkgs.comma];
    };
  };
}
