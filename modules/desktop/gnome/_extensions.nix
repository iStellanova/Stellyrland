{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.gnomeExtensions.dash-to-dock ];
}
