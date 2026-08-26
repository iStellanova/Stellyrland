{ lib, ... }:
let
  workspaceBinds = lib.listToAttrs (
    lib.concatMap (n: [
      {
        name = "Mod+${toString n}";
        value = "workspace-switch:${toString n}";
      }
      {
        name = "Mod+Shift+${toString n}";
        value = "window-move-to-workspace:${toString n}";
      }
    ]) (lib.range 1 7)
  );
in
{
  programs.umbriel.settings.keybinds = {
    "Mod+Q" = "spawn:kitty";
    "Mod+E" = "spawn:nautilus --new-window";
    "Mod+B" = "spawn:zen-beta";
    "Mod+V" = "spawn:zeditor";
    "Mod+Shift+L" = "spawn:noctalia msg lock";
    "Mod+C" = "window-close";
    "Alt+F4" = "window-close";
    "Mod+Z" = "window-toggle-floating";
    "Mod+P" = "window-toggle-maximize";
    "Alt+Return" = "window-toggle-fullscreen";
    "Mod+G" = "window-toggle-pinned";
    "Mod+A" = "window-focus-left";
    "Mod+D" = "window-focus-right";
    "Mod+H" = "window-focus-left";
    "Mod+L" = "window-focus-right";
    "Mod+K" = "window-focus-up";
    "Mod+J" = "window-focus-down";
    "Mod+Ctrl+Left" = "window-focus-left";
    "Mod+Ctrl+Right" = "window-focus-right";
    "Mod+Ctrl+Up" = "window-focus-up";
    "Mod+Ctrl+Down" = "window-focus-down";
    "Mod+Shift+S" = "window-move-to-scratchpad";
    "Mod+Alt+R" =
      "spawn:systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user restart noctalia";
    "Mod+Shift+Tab" = "spawn:noctalia msg panel-toggle wallpaper";
    "Mod+Shift+X" = "spawn:noctalia msg panel-toggle session";
    "Print" = "spawn:noctalia msg screenshot-region";
    "Shift+Print" = "spawn:noctalia msg screenshot-fullscreen";
    "Mod+Shift+R" = "spawn:pkill -SIGUSR1 gpu-screen-rec";
    "Mod+X" = "overview-toggle";
    "Mod+O" = "overview-toggle";
    "Mod+Space" = "workspace-set-layout:toggle";
    "Mod+Left" = "workspace-previous";
    "Mod+Right" = "workspace-next";
    "Mod+W" = "workspace-previous";
    "Mod+S" = "workspace-next";
    "Mod+BracketLeft" = "workspace-previous";
    "Mod+BracketRight" = "workspace-next";
    "Mod+Up" = "output-focus-up";
    "Mod+WheelUp" = "window-focus-left";
    "Mod+WheelDown" = "window-focus-right";
    "Mod+Shift+WheelUp" = "column-move-left";
    "Mod+Shift+WheelDown" = "column-move-right";
    "Mod+Alt+Right" = "window-modify-width:0.05";
    "Mod+Alt+Left" = "window-modify-width:-0.05";
    "Mod+MouseMiddle" = "overview-toggle";
    "Mod" = "spawn:noctalia msg panel-toggle launcher";
  }
  // workspaceBinds;
}
