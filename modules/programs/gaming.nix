{ config, lib, ... }:

{
  options.aspects.programs.gaming.enable = lib.mkEnableOption "Gaming suite (Steam, Gamemode, etc.)";

  config = lib.mkIf config.aspects.programs.gaming.enable {
    programs.gamemode.enable = true;
    programs.steam.enable = true;
    programs.gamescope.enable = true;
  };
}
