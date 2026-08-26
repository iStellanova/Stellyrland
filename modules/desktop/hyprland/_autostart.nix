{
  lib,
  lua,
  osConfig,
  ...
}:
let
  we = osConfig.desktop.hyprland.wallpaperEngine;
  screenRootFlags = lib.concatMapStringsSep " " (m: "--screen-root ${m}") we.screenRoots;
  weCmd =
    lib.optionalString (we.workshopId != "" && we.screenRoots != [ ])
      "hl.exec_cmd([[sleep 3 && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets ${screenRootFlags} --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/]])\n    ";
in
{
  wayland.windowManager.hyprland.settings.on = {
    _args = [
      "hyprland.start"
      (lua ''
        function()
          hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0")
          hl.exec_cmd("udiskie -a -s --file-manager nautilus")
          hl.exec_cmd([[sleep 3 && protonvpn-app --start-minimized]])
          ${weCmd}
        end'')
    ];
  };
}
