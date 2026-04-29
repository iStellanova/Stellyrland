{ config, lib, pkgs, identity, ... }:
{
  options.aspects.programs.yazi.enable = lib.mkEnableOption "Yazi file manager";
  config = lib.mkIf config.aspects.programs.yazi.enable {
    home-manager.users.${identity.name} = {
      programs.yazi = {
        enable = true;
        enableZshIntegration = true;
        shellWrapperName = "y";
        settings = {
          manager = {
            show_hidden = true;
            sort_by = "alphabetical";
            sort_sensitive = true;
            sort_reverse = false;
            sort_dir_first = true;
          };
        };
      };

      home.packages = with pkgs; [
        imagemagick
        poppler-utils
      ];
    };
  };
}
