{ config, lib, pkgs, ... }:

{
  options.aspects.programs.gaming.enable = lib.mkEnableOption "Gaming suite (Steam, Gamemode, etc.)";

  config = lib.mkIf config.aspects.programs.gaming.enable {
    programs.gamemode.enable = true;
    programs.steam.enable = true;
    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      heroic                   # Open-source launcher for Epic, GOG and Amazon Games
      prismlauncher            # A free, open source launcher for Minecraft
      protonup-qt              # Install and manage GE-Proton, Luxtorpeda & more
      r2modman                 # Mod manager for several games
    ];
  };
}
