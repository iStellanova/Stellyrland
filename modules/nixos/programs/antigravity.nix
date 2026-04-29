{ config, lib, pkgs, identity, ... }:
{
  options.aspects.programs.antigravity.enable = lib.mkEnableOption "Antigravity";
  config = lib.mkIf config.aspects.programs.antigravity.enable {
    home-manager.users.${identity.name} = {
      home.packages = with pkgs; [
        antigravity-fhs
      ];
    };
  };
}
