{ config, lib, pkgs, isDarwin, ... }:

{
  options.aspects.programs.gaming.enable = lib.mkEnableOption "Gaming suite (Steam, Gamemode, etc.)";

  config = lib.mkIf config.aspects.programs.gaming.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = [ "steam" "prismlauncher" ];
    })

    (lib.optionalAttrs (!isDarwin) {
      programs.gamemode.enable = true;
      programs.steam = {
        enable = true;
        extraPackages = with pkgs; [
          libcap
        ];
      };
      programs.gamescope.enable = true;

      environment.systemPackages = with pkgs; [
        heroic
        prismlauncher
        protonplus
        r2modman
      ];
    })
  ]);
}
