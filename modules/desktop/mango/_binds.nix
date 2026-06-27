{
  lib,
  osConfig,
  ...
}: let
  we = osConfig.desktop.mango.wallpaperEngine;
  screenRootFlags = lib.concatMapStringsSep " " (m: "--screen-root ${m}") we.screenRoots;
  wallpaperReloadBind =
    lib.optional (we.workshopId != "" && we.screenRoots != [])
    "SUPER+ALT,E,spawn_shell,pkill -f -9 linux-wallpaperengine && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets ${screenRootFlags} --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/";
in {
  wayland.windowManager.mango.settings = {
    bind =
      [
        # --- Core Applications ---
        "SUPER,Q,spawn,kitty"
        "SUPER,E,spawn,nautilus --new-window"
        "SUPER,B,spawn,zen"
        "SUPER,V,spawn,zeditor"

        # --- Session ---
        "SUPER+SHIFT,L,spawn,noctalia msg lock"

        # --- Window Management ---
        "SUPER,C,killclient"
        "ALT,F4,killclient"
        "SUPER,Z,togglefloating"
        "SUPER,P,zoom"
        "ALT,Return,togglefullscreen"

        # --- Overview ---
        "SUPER,Tab,toggleoverview"

        # --- Focus & Navigation ---
        "SUPER,A,focusstack,prev"
        "SUPER,D,focusstack,next"
        "SUPER,H,focusdir,l"
        "SUPER,L,focusdir,r"
        "SUPER,K,focusdir,u"
        "SUPER,J,focusdir,d"
        "SUPER+CTRL,Left,focusdir,l"
        "SUPER+CTRL,Right,focusdir,r"
        "SUPER+CTRL,Up,focusdir,u"
        "SUPER+CTRL,Down,focusdir,d"

        # --- Scratchpad ---
        "SUPER+SHIFT,S,toggle_scratchpad"

        # --- Noctalia ---
        "SUPER,F,spawn,noctalia msg panel-toggle launcher"
        "SUPER+ALT,R,spawn_shell,systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user restart noctalia"
        "SUPER+SHIFT,Tab,spawn,noctalia msg panel-toggle wallpaper"
        "SUPER+SHIFT,X,spawn,noctalia msg panel-toggle session"

        # --- Utilities ---
        "none,Print,spawn,noctalia msg screenshot-region"
        "SHIFT,Print,spawn,noctalia msg screenshot-fullscreen"
        "SUPER+SHIFT,R,spawn,pkill -SIGUSR1 gpu-screen-rec"

        # --- Window Resize ---
        "SUPER+ALT,Right,resizewin,50 0"
        "SUPER+ALT,Left,resizewin,-50 0"
        "SUPER+ALT,Up,resizewin,0 -50"
        "SUPER+ALT,Down,resizewin,0 50"

        # --- Tag Switching (scan codes for layout independence) ---
        "SUPER,code:10,view,1"
        "SUPER,code:11,view,2"
        "SUPER,code:12,view,3"
        "SUPER,code:13,view,4"
        "SUPER,code:14,view,5"
        "SUPER,code:15,view,6"
        "SUPER,code:16,view,7"
        "SUPER,code:17,view,8"
        "SUPER,code:18,view,9"

        # --- Move Window to Tag (silent — don't follow) ---
        "SUPER+SHIFT,1,tagsilent,1"
        "SUPER+SHIFT,2,tagsilent,2"
        "SUPER+SHIFT,3,tagsilent,3"
        "SUPER+SHIFT,4,tagsilent,4"
        "SUPER+SHIFT,5,tagsilent,5"
        "SUPER+SHIFT,6,tagsilent,6"
        "SUPER+SHIFT,7,tagsilent,7"
        "SUPER+SHIFT,8,tagsilent,8"
        "SUPER+SHIFT,9,tagsilent,9"

        # --- Tag Navigation ---
        "SUPER,Left,viewtoleft"
        "SUPER,Right,viewtoright"
        "SUPER,W,viewtoleft"
        "SUPER,S,viewtoright"
        "SUPER,bracketleft,viewtoleft"
        "SUPER,bracketright,viewtoright"
        "SUPER,Up,focusmon,+1"

        # --- Layout Toggle (cycles through circle_layout) ---
        "SUPER,space,switch_layout,0"

        # --- Scroller Proportion Cycle ---
        "SUPER+SHIFT,bracketright,switch_proportion_preset"
        "SUPER+SHIFT,bracketleft,switch_proportion_preset"
      ]
      ++ wallpaperReloadBind;

    # --- Release Binds ---
    bindr = [
    ];

    # --- Mouse Binds ---
    mousebind = [
      "SUPER,btn_left,movewin"
      "SUPER,btn_right,resizewin"
    ];

    # --- Scroll Axis Binds ---
    axisbind = [
      "ALT,down,focusdir,r"
      "ALT,up,focusdir,l"
      "SUPER,down,viewtoright"
      "SUPER,up,viewtoleft"
    ];
  };
}
