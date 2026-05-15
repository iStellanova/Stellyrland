{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$terminal" = "kitty";
    "$fileManager" = "nautilus";

    bind = [
      # --- Core Applications ---
      "$mainMod, Q, exec, $terminal"
      "$mainMod, E, exec, $fileManager --new-window"
      "$mainMod, B, exec, zen"
      "$mainMod, V, exec, zeditor"

      # --- System & Session Management ---
      "$mainMod+Shift, L, exec, noctalia msg lock"

      # --- Window Management ---
      "$mainMod, C, killactive"
      "Alt, F4, killactive"
      "$mainMod, A, togglefloating"
      "$mainMod, P, layoutmsg, promote"
      "Alt, Return, fullscreen"
      "$mainMod, G, movetoworkspace, +0" # Pin window to current workspace
      "$mainMod, Space, exec, hyprctl activeworkspace -j | jq -r 'if .tiledLayout == \"scrolling\" then \"dwindle\" else \"scrolling\" end as $l | \"workspace \\(.id),layout:\\($l)\"' | xargs hyprctl keyword"

      # --- Focus & Navigation (Scrolling / Dwindle / Master) ---
      "$mainMod, S, layoutmsg, focus l"
      "$mainMod, D, layoutmsg, focus r"
      "$mainMod, H, layoutmsg, focus l"
      "$mainMod, L, layoutmsg, focus r"
      "$mainMod, K, layoutmsg, focus u"
      "$mainMod, J, layoutmsg, focus d"
      "$mainMod+CTRL, left, layoutmsg, focus l"
      "$mainMod+CTRL, right, layoutmsg, focus r"
      "$mainMod+CTRL, up, layoutmsg, focus u"
      "$mainMod+CTRL, down, layoutmsg, focus d"

      # --- Workspace Switching (Using scan codes for layout independence) ---
      "$mainMod, code:10, split-workspace, 1"
      "$mainMod, code:11, split-workspace, 2"
      "$mainMod, code:12, split-workspace, 3"
      "$mainMod, code:13, split-workspace, 4"
      "$mainMod, code:14, split-workspace, 5"
      "$mainMod, code:15, split-workspace, 6"
      "$mainMod, code:16, split-workspace, 7"
      "$mainMod, code:17, split-workspace, 8"
      "$mainMod, code:18, split-workspace, 9"
      "$mainMod, code:19, split-workspace, 10"
      "$mainMod, code:20, split-workspace, 11"
      "$mainMod, code:21, split-workspace, 12"

      # --- Window Relocation (Move to Workspace) ---
      "$mainMod+SHIFT, 1, split-movetoworkspace, 1"
      "$mainMod+SHIFT, 2, split-movetoworkspace, 2"
      "$mainMod+SHIFT, 3, split-movetoworkspace, 3"
      "$mainMod+SHIFT, 4, split-movetoworkspace, 4"
      "$mainMod+SHIFT, 5, split-movetoworkspace, 5"
      "$mainMod+SHIFT, 6, split-movetoworkspace, 6"
      "$mainMod+SHIFT, 7, split-movetoworkspace, 7"
      "$mainMod+SHIFT, 8, split-movetoworkspace, 8"
      "$mainMod+SHIFT, 9, split-movetoworkspace, 9"
      "$mainMod+SHIFT, 0, split-movetoworkspace, 10"
      "$mainMod+SHIFT, code:20, split-movetoworkspace, 11"
      "$mainMod+SHIFT, code:21, split-movetoworkspace, 12"

      # --- Rapid Navigation ---
      "$mainMod, left, split-workspace, -1"
      "$mainMod, right, split-workspace, +1"
      "$mainMod, Z, split-workspace, -1"
      "$mainMod, X, split-workspace, +1"
      "$mainMod, bracketleft, split-workspace, -1"
      "$mainMod, bracketright, split-workspace, +1"
      "$mainMod, up, workspace, e+1"
      "$mainMod, down, workspace, empty"
      "$mainMod, grave, workspace, empty"
      "$mainMod+SHIFT, G, split-grabroguewindows"

      # --- Special Workspaces (Scratchpads) ---
      # magic: General purpose scratchpad
      # minimized: Used as a makeshift 'minimize' bin for active windows
      "$mainMod+SHIFT, S, movetoworkspace, special:magic"
      "$mainMod, F, movetoworkspacesilent, special:minimized"
      "$mainMod, R, togglespecialworkspace, minimized"

      # --- Noctalia Integration ---
      "$mainMod+Alt, R, exec, systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && pkill noctalia; noctalia"
      "$mainMod+SHIFT, Tab, exec, noctalia msg wallpaper-toggle"
      "$mainMod + Shift, X, exec, noctalia msg session-toggle"

      # --- Utilities ---
      ", Print, exec, hyprshot -m region -o ~/Pictures/Screenshots"
      "Shift, Print, exec, hyprshot -m output -o ~/Pictures/Screenshots"

      # --- Legacy/Alternative Navigation ---
      "ALT+SHIFT, Tab, cyclenext, prev"
      "ALT+SHIFT, Tab, bringactivetotop"

      # --- Mouse Bindings ---
      "$mainMod, mouse_down, workspace, e+1"
      "$mainMod, mouse_up, workspace, e-1"
      "ALT, mouse_down, layoutmsg, move +200"
      "ALT, mouse_up, layoutmsg, move -200"
    ];

    # Window Movements and Sizing
    binde = [
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
      "SUPER, Super_L, exec, noctalia msg launcher-toggle"
    ];
  };
}
