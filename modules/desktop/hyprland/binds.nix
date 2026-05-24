{
  inputs,
  lib,
  ...
}: let
  lua = lib.generators.mkLuaInline;
  bind = key: dispatcher: {_args = [key (lua dispatcher)];};
  bindOpts = key: dispatcher: opts: {_args = [key (lua dispatcher) (lua opts)];};

  mainMod = "SUPER";

  # All binds whose dispatcher is a static hl.dsp.* expression.
  # smw.* binds cannot go here — smw is a runtime require() value.
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
    (bind "${mainMod} + S" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + D" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + H" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + L" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + K" "hl.dsp.layout(\"focus u\")")
    (bind "${mainMod} + J" "hl.dsp.layout(\"focus d\")")
    (bind "${mainMod} + CTRL + left" "hl.dsp.layout(\"focus l\")")
    (bind "${mainMod} + CTRL + right" "hl.dsp.layout(\"focus r\")")
    (bind "${mainMod} + CTRL + up" "hl.dsp.layout(\"focus u\")")
    (bind "${mainMod} + CTRL + down" "hl.dsp.layout(\"focus d\")")

    # --- Rapid Navigation (non-smw) ---
    (bind "${mainMod} + up" "hl.dsp.focus({ workspace = \"e+1\" })")

    # --- Special Workspaces (Scratchpads) ---
    (bind "${mainMod} + SHIFT + S" "hl.dsp.window.move({ workspace = \"special:magic\" })")
    (bind "${mainMod} + F" "hl.dsp.exec_cmd(\"hyprctl dispatch movetoworkspacesilent special:minimized\")")
    (bind "${mainMod} + R" "hl.dsp.workspace.toggle_special(\"minimized\")")

    # --- Noctalia Integration ---
    (bind "${mainMod} + ALT + R" "hl.dsp.exec_cmd(\"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY && systemctl --user restart noctalia\")")
    (bind "${mainMod} + ALT + E" ''hl.dsp.exec_cmd([[pkill -f -9 linux-wallpaperengine && linux-wallpaperengine --assets-dir $HOME/ExtraDisk/SteamLibrary/steamapps/common/wallpaper_engine/assets --screen-root DP-2 --screen-root DP-3 --fps 60 --silent $HOME/ExtraDisk/SteamLibrary/steamapps/workshop/content/431960/3258032485/]])'')
    (bind "${mainMod} + SHIFT + Tab" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle wallpaper\")")
    (bind "${mainMod} + SHIFT + X" "hl.dsp.exec_cmd(\"noctalia msg panel-toggle session\")")

    # --- Utilities ---
    (bind "Print" "hl.dsp.exec_cmd(\"hyprshot -m region -o ~/Pictures/Screenshots\")")
    (bind "SHIFT + Print" "hl.dsp.exec_cmd(\"hyprshot -m output -o ~/Pictures/Screenshots\")")

    # --- Legacy/Alternative Navigation ---
    (bind "ALT + SHIFT + Tab" "hl.dsp.window.cycle_next(\"prev\")")
    (bind "ALT + SHIFT + Tab" "hl.dsp.window.bring_to_top()")

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
in {
  config = {
    # User-level Home Manager keybindings for Hyprland (Lua)
    flake.modules.homeManager.hyprlandBinds = {osConfig, ...}:
      lib.mkIf (osConfig ? aspects.desktop.hyprland && osConfig.aspects.desktop.hyprland.enable) {
        # All static binds expressed natively in Nix — HM serializes these to hl.bind(...) calls.
        wayland.windowManager.hyprland.settings.bind = staticBinds;

        # Only the smw plugin block lives here — it requires a runtime require() call
        # that cannot be expressed in the Nix type system.
        wayland.windowManager.hyprland.extraConfig = ''
          -- The nix derivation only installs the .so; the Lua library lives in the flake source.
          package.path = package.path .. ";${inputs.split-monitor-workspaces}/lua/?.lua"
          local smw = require("split-monitor-workspaces")
          smw.setup({
              workspace_count              = 5,
              keep_focused               = true,
              enable_notifications       = false,
              enable_persistent_workspaces = true,
              enable_wrapping            = false,
              monitor_priority           = { "DP-2", "DP-3" },
          })

          local mainMod = "SUPER"

          -- Workspace switching (scan codes for layout independence)
          hl.bind(mainMod .. " + code:10",  smw.workspace("1"))
          hl.bind(mainMod .. " + code:11",  smw.workspace("2"))
          hl.bind(mainMod .. " + code:12",  smw.workspace("3"))
          hl.bind(mainMod .. " + code:13",  smw.workspace("4"))
          hl.bind(mainMod .. " + code:14",  smw.workspace("5"))
          hl.bind(mainMod .. " + code:15",  smw.workspace("6"))
          hl.bind(mainMod .. " + code:16",  smw.workspace("7"))
          hl.bind(mainMod .. " + code:17",  smw.workspace("8"))
          hl.bind(mainMod .. " + code:18",  smw.workspace("9"))
          hl.bind(mainMod .. " + code:19",  smw.workspace("10"))
          hl.bind(mainMod .. " + code:20",  smw.workspace("11"))
          hl.bind(mainMod .. " + code:21",  smw.workspace("12"))

          -- Move window to workspace silently
          hl.bind(mainMod .. " + SHIFT + 1",       smw.move_to_workspace_silent("1"))
          hl.bind(mainMod .. " + SHIFT + 2",       smw.move_to_workspace_silent("2"))
          hl.bind(mainMod .. " + SHIFT + 3",       smw.move_to_workspace_silent("3"))
          hl.bind(mainMod .. " + SHIFT + 4",       smw.move_to_workspace_silent("4"))
          hl.bind(mainMod .. " + SHIFT + 5",       smw.move_to_workspace_silent("5"))
          hl.bind(mainMod .. " + SHIFT + 6",       smw.move_to_workspace_silent("6"))
          hl.bind(mainMod .. " + SHIFT + 7",       smw.move_to_workspace_silent("7"))
          hl.bind(mainMod .. " + SHIFT + 8",       smw.move_to_workspace_silent("8"))
          hl.bind(mainMod .. " + SHIFT + 9",       smw.move_to_workspace_silent("9"))
          hl.bind(mainMod .. " + SHIFT + 0",       smw.move_to_workspace_silent("10"))
          hl.bind(mainMod .. " + SHIFT + code:20", smw.move_to_workspace_silent("11"))
          hl.bind(mainMod .. " + SHIFT + code:21", smw.move_to_workspace_silent("12"))

          -- Cycle workspaces
          hl.bind(mainMod .. " + left",         smw.cycle_workspaces("prev"))
          hl.bind(mainMod .. " + right",        smw.cycle_workspaces("next"))
          hl.bind(mainMod .. " + Z",            smw.cycle_workspaces("prev"))
          hl.bind(mainMod .. " + X",            smw.cycle_workspaces("next"))
          hl.bind(mainMod .. " + bracketleft",  smw.cycle_workspaces("prev"))
          hl.bind(mainMod .. " + bracketright", smw.cycle_workspaces("next"))
          hl.bind(mainMod .. " + down",         smw.workspace("empty"))
          hl.bind(mainMod .. " + grave",        smw.workspace("empty"))
          hl.bind(mainMod .. " + SHIFT + G",    smw.grab_rogue_windows())

          -- Mouse scroll workspace navigation
          hl.bind(mainMod .. " + mouse_down",   smw.cycle_workspaces("next"))
          hl.bind(mainMod .. " + mouse_up",     smw.cycle_workspaces("prev"))

          -- exec_cmd runs in a child process, avoiding IPC deadlock when querying active workspace.
          hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd([[data=$(hyprctl activeworkspace -j); id=$(echo "$data" | grep '"id"' | head -1 | tr -dc '0-9'); layout=$(echo "$data" | grep tiledLayout | awk -F'"' '{print $4}'); [ "$layout" = "scrolling" ] && next=dwindle || next=scrolling; hyprctl eval "hl.workspace_rule({ workspace = '$id', layout = '$next' })"]]))
        '';
      };
  };
}
