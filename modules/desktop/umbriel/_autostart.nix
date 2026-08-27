{ lib, osConfig, ... }:
let
  wallpaper = osConfig.desktop.umbriel.wallpaperEngine;
  wallpaperArgs = lib.concatMapStringsSep " " (m: "--screen-root ${m}") wallpaper.screenRoots;
  wallpaperCommand = "sleep 3 && linux-wallpaperengine --assets-dir ${wallpaper.steamLibrary}/steamapps/common/wallpaper_engine/assets ${wallpaperArgs} --layer bottom --fps 60 --silent ${wallpaper.steamLibrary}/steamapps/workshop/content/431960/${wallpaper.workshopId}/";
in
{
  programs.umbriel.settings.general.autostart = [
    "systemctl --user start noctalia.service"
    "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0"
    "udiskie -a -s --file-manager nautilus"
    "sleep 3 && protonvpn-app --start-minimized"
  ]
  ++ lib.optional (wallpaper.workshopId != "" && wallpaper.screenRoots != [ ]) wallpaperCommand;
}
