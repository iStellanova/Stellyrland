{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  lua = lib.generators.mkLuaInline;
  bind = key: dispatcher: {_args = [key (lua dispatcher)];};
  bindOpts = key: dispatcher: opts: {_args = [key (lua dispatcher) (lua opts)];};
  hyprsplitLua = inputs.hyprsplit.packages.${pkgs.stdenv.hostPlatform.system}.hyprsplitlua;

  mainMod = "SUPER";

  # All binds whose dispatcher is a static hl.dsp.* expression.
  # smw.* binds cannot go here — smw is a runtime require() value.
  # Wallpaper engine reload bind is derived dynamically from osConfig below.
  staticBinds = [
    # --- Core Applications ---
    (bind "${mainMod} + Q" "hl.dsp.exec_cmd(\"kitty\")")
    (bind "${mainMod} + E" "hl.dsp.exec_cmd(\"nautilus --new-window\")")
    (bind "${mainMod} + B" "hl.dsp.exec_cmd(\"zen\")")
    (bind "${mainMod} + V" "hl.dsp.exec_cmd(\"zeditor\")")

    # --- System & Session Management ---
    (bind "${mainMod} + SHIFT + L" "hl.dsp.exec_cmd(\"noctalia msg lock\")")

    # --- Window Management ---
    (bind "${mainMod} + C" "hl.dsp.window.close()")
    (bind "ALT + F4" "hl.dsp.window.close()")
    (bind "${mainMod} + A" "hl.dsp.window.float({ action = \"toggle\" })")
    (bind "${mainMod} + P" "hl.dsp.layout(\"promote\")")
    (bind "ALT + Return" "hl.dsp.window.fullscreen()")
    (bind "${mainMod} + G" "hl.dsp.window.move({ workspace = \"+0\" })") # pin window to active workspace (movetoworkspace +0)

    # --- Focus & Navigation ---
    (bind "${mainMod} + Z" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + X" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + H" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + L" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + K" "hl.dsp.layout(\"focus u\")")
    (bind "${mainMod} + J" "hl.dsp.layout(\"focus d\")")
    (bind "${mainMod} + CTRL + left" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + CTRL + right" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + CTRL + up" "hl.dsp.layout(\"focus u\")")
    (bind "${mainMod} + CTRL + down" "hl.dsp.layout(\"focus d\")")

    # --- Special Workspaces (Scratchpads) ---
    (bind "${mainMod} + SHIFT + S" "hl.dsp.window.move({ workspace = \"special:magic\" })")

    # --- Noctalia Integration ---
    (bind "${mainMod} + ALT + R" "hl.dsp.exec_cmd(\"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user restart noctalia\")")
    (bind "${mainMod} + SHIFT + Tab" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle wallpaper\")")
    (bind "${mainMod} + SHIFT + X" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle session\")")

    # --- Utilities ---
    (bind "Print" "hl.dsp.exec_cmd(\"noctalia msg screenshot-region\")")
    (bind "SHIFT + Print" "hl.dsp.exec_cmd(\"noctalia msg screenshot-fullscreen\")")

    # --- Mouse Scroll Binds (non-smw) ---
    (bind "ALT + mouse_down" "hl.dsp.layout(\"move +200\")")
    (bind "ALT + mouse_up" "hl.dsp.layout(\"move -200\")")

    # --- Repeating Window Resize ---
    (bindOpts "${mainMod} + ALT + right" "hl.dsp.window.resize({ x = 50,  y = 0,   relative = true })" "{ repeating = true }")
    (bindOpts "${mainMod} + ALT + left" "hl.dsp.window.resize({ x = -50, y = 0,   relative = true })" "{ repeating = true }")
    (bindOpts "${mainMod} + ALT + up" "hl.dsp.window.resize({ x = 0,   y = -50, relative = true })" "{ repeating = true }")
    (bindOpts "${mainMod} + ALT + down" "hl.dsp.window.resize({ x = 0,   y = 50,  relative = true })" "{ repeating = true }")

    # --- Mouse Drag/Resize ---
    (bindOpts "${mainMod} + mouse:272" "hl.dsp.window.drag()" "{ mouse = true }")
    (bindOpts "${mainMod} + mouse:273" "hl.dsp.window.resize()" "{ mouse = true }")

    # --- Noctalia Launcher (release bind) ---
    (bindOpts "${mainMod} + Super_L" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle launcher\")" "{ release = true }")
  ];

  we = osConfig.desktop.hyprland.wallpaperEngine;
  wallpaperReloadBind = lib.optional (we.workshopId != "") (
    bind "${mainMod} + ALT + E" "hl.dsp.exec_cmd([[pkill -f -9 linux-wallpaperengine && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets --screen-root DP-2 --screen-root DP-3 --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/]])"
  );
in {
  # All static binds expressed natively in Nix — HM serializes these to hl.bind(...) calls.
  wayland.windowManager.hyprland.settings.bind = staticBinds ++ wallpaperReloadBind;

  # hyprsplit binds require a runtime require() and cannot be expressed in the Nix type system.
  wayland.windowManager.hyprland.extraConfig = ''
    package.path = package.path .. ";${hyprsplitLua}/share/?/init.lua"
    local hs = require("hyprsplit")
    hs.config({
        num_workspaces        = 7,
        persistent_workspaces = true,
        force_monitor_priority = true,
    })
    hs.monitor_priority({ "DP-2", "DP-3" })

    local mainMod = "SUPER"

    -- Workspace switching (scan codes for layout independence)
    hl.bind(mainMod .. " + code:10",  hs.dsp.focus({ workspace = 1 }))
    hl.bind(mainMod .. " + code:11",  hs.dsp.focus({ workspace = 2 }))
    hl.bind(mainMod .. " + code:12",  hs.dsp.focus({ workspace = 3 }))
    hl.bind(mainMod .. " + code:13",  hs.dsp.focus({ workspace = 4 }))
    hl.bind(mainMod .. " + code:14",  hs.dsp.focus({ workspace = 5 }))
    hl.bind(mainMod .. " + code:15",  hs.dsp.focus({ workspace = 6 }))
    hl.bind(mainMod .. " + code:16",  hs.dsp.focus({ workspace = 7 }))
    hl.bind(mainMod .. " + code:17",  hs.dsp.focus({ workspace = 8 }))
    hl.bind(mainMod .. " + code:18",  hs.dsp.focus({ workspace = 9 }))
    hl.bind(mainMod .. " + code:19",  hs.dsp.focus({ workspace = 10 }))
    hl.bind(mainMod .. " + code:20",  hs.dsp.focus({ workspace = 11 }))
    hl.bind(mainMod .. " + code:21",  hs.dsp.focus({ workspace = 12 }))

    -- Move window to workspace silently
    hl.bind(mainMod .. " + SHIFT + 1",       hs.dsp.window.move({ workspace = 1,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 2",       hs.dsp.window.move({ workspace = 2,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 3",       hs.dsp.window.move({ workspace = 3,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 4",       hs.dsp.window.move({ workspace = 4,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 5",       hs.dsp.window.move({ workspace = 5,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 6",       hs.dsp.window.move({ workspace = 6,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 7",       hs.dsp.window.move({ workspace = 7,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 8",       hs.dsp.window.move({ workspace = 8,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 9",       hs.dsp.window.move({ workspace = 9,  follow = false }))
    hl.bind(mainMod .. " + SHIFT + 0",       hs.dsp.window.move({ workspace = 10, follow = false }))
    hl.bind(mainMod .. " + SHIFT + code:20", hs.dsp.window.move({ workspace = 11, follow = false }))
    hl.bind(mainMod .. " + SHIFT + code:21", hs.dsp.window.move({ workspace = 12, follow = false }))

    -- Cycle and navigate workspaces (non-wrapping; use r+1/r-1 to wrap)
    hl.bind(mainMod .. " + left",         hs.dsp.focus({ workspace = "-1" }))
    hl.bind(mainMod .. " + right",        hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + W",            hs.dsp.focus({ workspace = "-1" }))
    hl.bind(mainMod .. " + S",            hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + bracketleft",  hs.dsp.focus({ workspace = "-1" }))
    hl.bind(mainMod .. " + bracketright", hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + up",           hs.dsp.focus({ workspace = "m+1" }))
    hl.bind(mainMod .. " + down",         hs.dsp.focus({ workspace = "empty" }))
    hl.bind(mainMod .. " + grave",        hs.dsp.focus({ workspace = "empty" }))
    hl.bind(mainMod .. " + SHIFT + G",    hs.dsp.grab_rogue_windows())

    -- Mouse scroll workspace navigation
    hl.bind(mainMod .. " + mouse_down",   hs.dsp.focus({ workspace = "+1" }))
    hl.bind(mainMod .. " + mouse_up",     hs.dsp.focus({ workspace = "-1" }))

    -- exec_cmd runs in a child process, avoiding IPC deadlock when querying active workspace.
    hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd([[data=$(hyprctl activeworkspace -j); id=$(echo "$data" | grep '"id"' | head -1 | tr -dc '0-9'); layout=$(echo "$data" | grep tiledLayout | awk -F'"' '{print $4}'); [ "$layout" = "scrolling" ] && next=dwindle || next=scrolling; hyprctl eval "hl.workspace_rule({ workspace = '$id', layout = '$next' })"]]))

    if hl.plugin and hl.plugin.scrolloverview then
        hl.plugin.scrolloverview.configure({
            scale = 0.5,
            workspace_gap = 50,
            shadow = { enabled = false },
        })
        hl.bind(mainMod .. " + D", function()
            hl.plugin.scrolloverview.overview("toggle")
        end)
    end
  '';
}
