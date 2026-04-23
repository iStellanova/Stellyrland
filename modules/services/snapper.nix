{ config, lib, ... }:

{
  options.aspects.services.snapper.enable = lib.mkEnableOption "Snapper btrfs snapshot service";

  config = lib.mkIf config.aspects.services.snapper.enable {
    services.snapper.configs = {
      home = {
        SUBVOLUME = "/home";
        ALLOW_USERS = [ "stellanova" ];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
      };
    };
  };
}
