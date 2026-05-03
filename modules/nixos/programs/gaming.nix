{ config, lib, pkgs, ... }:

{
  options.aspects.programs.gaming.enable = lib.mkEnableOption "Gaming suite (Steam, Gamemode, etc.)";

  config = lib.mkIf config.aspects.programs.gaming.enable {
    programs.gamemode.enable = true; # Enable Gamemode, a performance optimization tool.
    programs.steam = {
      enable = true;
      extraPackages = with pkgs; [
        libcap
      ];
    };
    programs.gamescope.enable = true; # Enable Gamescope, a Wayland compositor for gaming.

    environment.systemPackages = with pkgs; [
      heroic                   # Open-source launcher for Epic, GOG and Amazon Games
      prismlauncher            # A free, open source launcher for Minecraft
      protonplus               # Install and manage GE-Proton, Luxtorpeda & more
      r2modman                 # Mod manager for several games
    ];
  };
}
