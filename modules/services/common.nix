{ config, lib, ... }:

{
  options.aspects.services.common.enable = lib.mkEnableOption "Common system services" // { default = true; };

  config = lib.mkIf config.aspects.services.common.enable {
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };

    services.gnome.tinysparql.enable = true;
    services.gnome.localsearch.enable = true;
    services.flatpak.enable = true;
    programs.seahorse.enable = true;
  };
}
