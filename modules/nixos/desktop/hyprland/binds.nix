{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "nautilus";

    bind = [
      # Apps
      "$mainMod, Q, exec, $terminal"
      "$mainMod, E, exec, $fileManager --new-window"
      "$mainMod, B, exec, zen-browser"
      "$mainMod, Space, exec, rofi -show drun"
      "$mainMod, B, exec, zeditor"

      # Session
      "$mainMod+Shift, L, exec, noctalia-shell ipc call lockScreen lock"

      # Windows
      "$mainMod, C, killactive"
      "Alt, F4, killactive"
      "$mainMod, A, togglefloating"
      "$mainMod, P, layoutmsg, promote"
      "$mainMod, O, togglesplit"
      "Alt, Return, fullscreen"
      "$mainMod, G, movetoworkspace, +0"

      # Focus
      "$mainMod, H, layoutmsg, focus l"
      "$mainMod, L, layoutmsg, focus r"
      "$mainMod, K, layoutmsg, focus u"
      "$mainMod, J, layoutmsg, focus d"
      "$mainMod+CTRL, left, layoutmsg, focus l"
      "$mainMod+CTRL, right, layoutmsg, focus r"
      "$mainMod+CTRL, up, layoutmsg, focus u"
      "$mainMod+CTRL, down, layoutmsg, focus d"

      # Workspaces
      "$mainMod, code:10, workspace, 1"
      "$mainMod, code:11, workspace, 2"
      "$mainMod, code:12, workspace, 3"
      "$mainMod, code:13, workspace, 4"
      "$mainMod, code:14, workspace, 5"
      "$mainMod, code:15, workspace, 6"
      "$mainMod, code:16, workspace, 7"
      "$mainMod, code:17, workspace, 8"
      "$mainMod, code:18, workspace, 9"
      "$mainMod, code:19, workspace, 10"
      "$mainMod, code:20, workspace, 11"
      "$mainMod, code:21, workspace, 12"

      # Move to Workspace
      "$mainMod+SHIFT, 1, movetoworkspace, 1"
      "$mainMod+SHIFT, 2, movetoworkspace, 2"
      "$mainMod+SHIFT, 3, movetoworkspace, 3"
      "$mainMod+SHIFT, 4, movetoworkspace, 4"
      "$mainMod+SHIFT, 5, movetoworkspace, 5"
      "$mainMod+SHIFT, 6, movetoworkspace, 6"
      "$mainMod+SHIFT, 7, movetoworkspace, 7"
      "$mainMod+SHIFT, 8, movetoworkspace, 8"
      "$mainMod+SHIFT, 9, movetoworkspace, 9"
      "$mainMod+SHIFT, 0, movetoworkspace, 10"
      "$mainMod+SHIFT, code:20, movetoworkspace, 11"
      "$mainMod+SHIFT, code:21, movetoworkspace, 12"

      # Navigate
      "$mainMod, left, workspace, -1"
      "$mainMod, right, workspace, +1"
      "$mainMod, Z, workspace, -1"
      "$mainMod, X, workspace, +1"
      "$mainMod, bracketleft, workspace, -1"
      "$mainMod, bracketright, workspace, +1"
      "$mainMod, up, workspace, e+1"
      "$mainMod, down, workspace, empty"
      "$mainMod, grave, workspace, empty"

      # Special
      "$mainMod+SHIFT, S, movetoworkspace, special:magic"
      "$mainMod, F, movetoworkspacesilent, special:minimized"
      "$mainMod, R, togglespecialworkspace, minimized"
      "$mainMod+Alt, R, exec, systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && pkill noctalia-shell; noctalia-shell"
      "$mainMod+SHIFT, Tab, exec, noctalia-shell ipc call wallpaper toggle"
      "$mainMod + Shift, X, exec, noctalia-shell ipc call sessionMenu toggle"

      # Clipboard
      "$mainMod, V, exec, kitty --class cliphist-fzf -e sh -c 'cliphist list | fzf --no-scrollbar | cliphist decode | wl-copy'"

      # Screenshot
      ", Print, exec, hyprshot -m region -o ~/Pictures/Screenshots"
      "Shift, Print, exec, hyprshot -m output -o ~/Pictures/Screenshots"

      # Alt-Tab
      "ALT+SHIFT, Tab, cyclenext, prev"
      "ALT+SHIFT, Tab, bringactivetotop"

      # Scroll
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
      "ALT, mouse_down, layoutmsg, move +200"
      "ALT, mouse_up, layoutmsg, move -200"
    ];

    # Window Movements and Sizing
    binde = [
      "$mainMod, S, layoutmsg, move -col"
      "$mainMod, D, layoutmsg, move +col"
      "$mainMod+Alt, right, resizeactive, 50 0"
      "$mainMod+Alt, left, resizeactive, -50 0"
      "$mainMod+Alt, up, resizeactive, 0 -50"
      "$mainMod+Alt, down, resizeactive, 0 50"
    ];

    # Window Resizing
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
    ];

    # Noctalia Launcher
    bindr = [
      "SUPER, Super_L, exec, noctalia-shell ipc call launcher toggle"
    ];
  };
}
