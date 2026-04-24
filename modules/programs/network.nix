{ config, lib, pkgs, ... }:

{
  options.aspects.programs.network.enable = lib.mkEnableOption "Network-related applications";

  config = lib.mkIf config.aspects.programs.network.enable {
    environment.systemPackages = with pkgs; [
      proton-vpn               # Official Proton VPN Linux app
    ];
  };
}
