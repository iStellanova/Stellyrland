{ config, lib, pkgs, ... }:

{
  options.aspects.programs.utils.enable = lib.mkEnableOption "Miscellaneous GUI utilities";

  config = lib.mkIf config.aspects.programs.utils.enable {
    environment.systemPackages = with pkgs; [
      gnome-disk-utility       # A utility for managing disk drives and media
      planify                  # Task manager with Todoist support
      resources                # Resource monitor
      proton-vpn               # Official Proton VPN Linux app
    ];
  };
}
