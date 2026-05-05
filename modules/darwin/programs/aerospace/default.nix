{ config, lib, identity, ... }:

{
  options.aspects.programs.aerospace.enable = lib.mkEnableOption "AeroSpace window manager";

  config = lib.mkIf config.aspects.programs.aerospace.enable {
    # Install AeroSpace via Homebrew as it's the recommended way for macOS
    homebrew.casks = [ "nikitabobko/tap/aerospace" ];

    # Configure AeroSpace
    home-manager.users.${identity.name} = {
      home.file.".aerospace.toml".text = ''
        # Config version for compatibility and deprecations
        config-version = 2

        # GLOBAL SETTINGS
        on-focus-changed = ['move-mouse window-lazy-center']

        # After startup commands
        after-startup-command = [
          'exec-and-forget osascript -e "tell application \"System Events\" to set autohide of dock preferences to true"',
          'exec-and-forget open -a AutoRaise',
        ]

        # Start AeroSpace at login
        start-at-login = true

        # Normalizations
        enable-normalization-flatten-containers = true
        enable-normalization-opposite-orientation-for-nested-containers = true

        # Layout settings
        accordion-padding = 30
        default-root-container-layout = 'tiles'
        default-root-container-orientation = 'auto'

        # Mouse follows focus
        on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
        automatically-unhide-macos-hidden-apps = false

        # Persistent workspaces
        persistent-workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

        [key-mapping]
        preset = 'qwerty'

        [gaps]
        inner.horizontal = 10
        inner.vertical =   10
        outer.left =       10
        outer.bottom =     10
        outer.top =        10
        outer.right =      10

        [mode.main.binding]
        alt-q = 'exec-and-forget open -n -a Kitty'
        alt-slash = 'layout tiles horizontal vertical'
        alt-comma = 'layout accordion horizontal vertical'

        # Focus
        alt-h = 'focus left'
        alt-j = 'focus down'
        alt-k = 'focus up'
        alt-l = 'focus right'

        # Move
        alt-shift-h = 'move left'
        alt-shift-j = 'move down'
        alt-shift-k = 'move up'
        alt-shift-l = 'move right'

        # Resize
        alt-minus = 'resize smart -50'
        alt-equal = 'resize smart +50'

        # Workspaces
        alt-1 = 'workspace 1'
        alt-2 = 'workspace 2'
        alt-3 = 'workspace 3'
        alt-4 = 'workspace 4'
        alt-5 = 'workspace 5'
        alt-6 = 'workspace 6'
        alt-7 = 'workspace 7'
        alt-8 = 'workspace 8'
        alt-9 = 'workspace 9'

        # Move to workspace
        alt-shift-1 = 'move-node-to-workspace 1'
        alt-shift-2 = 'move-node-to-workspace 2'
        alt-shift-3 = 'move-node-to-workspace 3'
        alt-shift-4 = 'move-node-to-workspace 4'
        alt-shift-5 = 'move-node-to-workspace 5'
        alt-shift-6 = 'move-node-to-workspace 6'
        alt-shift-7 = 'move-node-to-workspace 7'
        alt-shift-8 = 'move-node-to-workspace 8'
        alt-shift-9 = 'move-node-to-workspace 9'

        # Management
        alt-tab = 'workspace-back-and-forth'
        alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'
        alt-shift-semicolon = 'mode service'

        [mode.service.binding]
        esc = ['reload-config', 'mode main']
        r = ['flatten-workspace-tree', 'mode main']
        f = ['layout floating tiling', 'mode main']
        backspace = ['close-all-windows-but-current', 'mode main']
        alt-shift-h = ['join-with left', 'mode main']
        alt-shift-j = ['join-with down', 'mode main']
        alt-shift-k = ['join-with up', 'mode main']
        alt-shift-l = ['join-with right', 'mode main']
      '';
    };
  };
}
