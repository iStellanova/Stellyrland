{ config, lib, pkgs, ... }:
{
  options.aspects.programs.antigravity.enable = lib.mkEnableOption "Antigravity";
  config = lib.mkIf config.aspects.programs.antigravity.enable {
    home-manager.users.stellanova = {
      home.packages = with pkgs; [
        antigravity-fhs
      ];
    };
  };
}
