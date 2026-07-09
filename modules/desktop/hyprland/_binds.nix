{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  lua = lib.generators.mkLuaInline;
  bind = key: dispatcher: {
    _args = [
      key
      (lua dispatcher)
    ];
  };
  bindOpts = key: dispatcher: opts: {
    _args = [
      key
      (lua dispatcher)
      (lua opts)
    ];
  };
  hyprsplitLua = inputs.hyprsplit.packages.${pkgs.stdenv.hostPlatform.system}.hyprsplitlua;

  mainMod = "SUPER";

  # Static hl.dsp.* dispatcher binds only; smw.* require runtime require() so go below. Wallpaper reload derived from osConfig.
  staticBinds = [
    # Core Applications
    (bind "${mainMod} + Q" "hl.dsp.exec_cmd(\"kitty\")")
    (bind "${mainMod} + E" "hl.dsp.exec_cmd(\"nautilus --new-window\")")
    (bind "${mainMod} + B" "hl.dsp.exec_cmd(\"zen\")")
    (bind "${mainMod} + V" "hl.dsp.exec_cmd(\"zeditor\")")

    # System & Session
    (bind "${mainMod} + SHIFT + L" "hl.dsp.exec_cmd(\"noctalia msg lock\")")

    # Window Management
    (bind "${mainMod} + C" "hl.dsp.window.close()")
    (bind "ALT + F4" "hl.dsp.window.close()")
    (bind "${mainMod} + Z" "hl.dsp.window.float({ action = \"toggle\" })")
    (bind "${mainMod} + P" "hl.dsp.layout(\"promote\")")
    (bind "ALT + Return" "hl.dsp.window.fullscreen()")
    (bind "${mainMod} + G" "hl.dsp.window.move({ workspace = \"+0\" })") # +0 pins to current workspace

    # Focus & Navigation
    (bind "${mainMod} + A" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + D" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + H" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + L" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + K" "hl.dsp.layout(\"focus u\")")
    (bind "${mainMod} + J" "hl.dsp.layout(\"focus d\")")
    (bind "${mainMod} + CTRL + left" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + CTRL + right" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + CTRL + up" "hl.dsp.layout(\"focus u\")")
    (bind "${mainMod} + CTRL + down" "hl.dsp.layout(\"focus d\")")

    # Special Workspaces (Scratchpads)
    (bind "${mainMod} + SHIFT + S" "hl.dsp.window.move({ workspace = \"special:magic\" })")

    # Noctalia Integration
    (bind "${mainMod} + ALT + R" "hl.dsp.exec_cmd(\"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user restart noctalia\")")
    (bind "${mainMod} + SHIFT + Tab" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle wallpaper\")")
    (bind "${mainMod} + SHIFT + X" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle session\")")

    # Utilities
    (bind "Print" "hl.dsp.exec_cmd(\"noctalia msg screenshot-region\")")
    (bind "SHIFT + Print" "hl.dsp.exec_cmd(\"noctalia msg screenshot-fullscreen\")")
    (bind "${mainMod} + SHIFT + R" "hl.dsp.exec_cmd(\"pkill -SIGUSR1 gpu-screen-rec\")")

    # Mouse Scroll (non-smw)
    (bind "ALT + mouse_down" "hl.dsp.layout(\"move +200\")")
    (bind "ALT + mouse_up" "hl.dsp.layout(\"move -200\")")

    # Repeating Window Resize
    (bindOpts "${mainMod} + ALT + right" "hl.dsp.window.resize({ x = 50,  y = 0,   relative = true })"
      "{ repeating = true }"
    )
    (bindOpts "${mainMod} + ALT + left" "hl.dsp.window.resize({ x = -50, y = 0,   relative = true })"
      "{ repeating = true }"
    )
    (bindOpts "${mainMod} + ALT + up" "hl.dsp.window.resize({ x = 0,   y = -50, relative = true })"
      "{ repeating = true }"
    )
    (bindOpts "${mainMod} + ALT + down" "hl.dsp.window.resize({ x = 0,   y = 50,  relative = true })"
      "{ repeating = true }"
    )

    # Mouse Drag/Resize
    (bindOpts "${mainMod} + mouse:272" "hl.dsp.window.drag()" "{ mouse = true }")
    (bindOpts "${mainMod} + mouse:273" "hl.dsp.window.resize()" "{ mouse = true }")

    # Noctalia Launcher (release bind)
    (bindOpts "${mainMod} + Super_L" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle launcher\")"
      "{ release = true }"
    )
  ];

  workspaceNumbers = lib.range 1 12;
  scanCode = wsnum: "code:${toString (9 + wsnum)}";
  moveKey = wsnum: if wsnum <= 9 then toString wsnum else if wsnum == 10 then "0" else scanCode wsnum;
  workspaceBind = wsnum: "SHIFT + ${moveKey wsnum}";

  workspaceFocusBinds = lib.concatMapStringsSep "\n" (
    wsnum: "    hl.bind(mainMod .. \" + ${scanCode wsnum}\", hs.dsp.focus({ workspace = ${toString wsnum} }))"
  ) workspaceNumbers;
  workspaceMoveBinds = lib.concatMapStringsSep "\n" (
    wsnum: "    hl.bind(mainMod .. \" + ${workspaceBind wsnum}\", hs.dsp.window.move({ workspace = ${toString wsnum}, follow = false }))"
  ) workspaceNumbers;

  we = osConfig.desktop.hyprland.wallpaperEngine;
  screenRootFlags = lib.concatMapStringsSep " " (m: "--screen-root ${m}") we.screenRoots;
  hp = osConfig.desktop.hyprland.hyprsplit;
  monitorPriorityLua =
    lib.optionalString (hp.monitorPriority != [ ])
      "hs.monitor_priority({ ${lib.concatMapStringsSep ", " (m: "\"${m}\"") hp.monitorPriority} })";
  wallpaperReloadBind = lib.optional (we.workshopId != "" && we.screenRoots != [ ]) (
    bind "${mainMod} + ALT + E" "hl.dsp.exec_cmd([[pkill -f -9 linux-wallpaperengine && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets ${screenRootFlags} --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/]])"
  );
in
{
  wayland.windowManager.hyprland.settings.bind = staticBinds ++ wallpaperReloadBind;

  wayland.windowManager.hyprland.extraLuaFiles."hyprsplit-binds" = ''
    package.path = package.path .. ";${hyprsplitLua}/share/?/init.lua"
    local hs = require("hyprsplit")
    hs.config({
        num_workspaces        = ${toString hp.numWorkspaces},
        persistent_workspaces = true,
        force_monitor_priority = true,
    })
    ${monitorPriorityLua}

    local mainMod = "${mainMod}"

    -- Workspace switching (scan codes for layout-independence)
${workspaceFocusBinds}

    -- Move window to workspace silently (no follow)
${workspaceMoveBinds}

    -- Navigate workspaces (non-wrapping)
    hl.bind(mainMod .. " + left",         hs.dsp.focus({ workspace = "-1" }))
    hl.bind(mainMod .. " + right",        hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + W",            hs.dsp.focus({ workspace = "-1" }))
    hl.bind(mainMod .. " + S",            hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + bracketleft",  hs.dsp.focus({ workspace = "-1" }))
    hl.bind(mainMod .. " + bracketright", hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + up",           hs.dsp.focus({ workspace = "m+1" }))
    hl.bind(mainMod .. " + SHIFT + G",    hs.dsp.grab_rogue_windows())

    -- Mouse scroll workspace navigation
    hl.bind(mainMod .. " + mouse_down",   hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + mouse_up",     hs.dsp.focus({ workspace = "-1" }))

    -- Layout toggle: exec_cmd avoids IPC deadlock when querying active workspace
    hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd([[data=$(hyprctl activeworkspace -j); id=$(echo "$data" | grep '"id"' | head -1 | tr -dc '0-9'); layout=$(echo "$data" | grep tiledLayout | awk -F'"' '{print $4}'); [ "$layout" = "scrolling" ] && next=dwindle || next=scrolling; hyprctl eval "hl.workspace_rule({ workspace = '$id', layout = '$next' })"]]))
  '';
}
