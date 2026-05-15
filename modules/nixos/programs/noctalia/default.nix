{ config, lib, identity, ... }:

{
  options.aspects.programs.noctalia-shell.enable = lib.mkEnableOption "Noctalia shell environment";

  config = lib.mkIf config.aspects.programs.noctalia-shell.enable {
    home-manager.users.${identity.name} = { inputs, pkgs, osConfig, ... }:
      {
        imports = [
          inputs.noctalia-shell.homeModules.default
        ];

        programs.noctalia = {
          enable = true;
          systemd.enable = true;

          # Main configuration (generates config.toml)
          config = {
            shell = {
              scale = 1.0;
              font = "Sans";
            };
            theme = {
              mode = "dark";
              # source = "custom"; # Uncomment and set customPalette if needed
            };
            wallpaper = {
              enabled = true;
              directory = "${identity.home}/Pictures/wallpapers/static";
            };
            desktop_widgets = {
              enabled = true;
            };
            bar = {
              main = {
                position = "top";
              };
            };
          };

          # Widget configuration (generates desktop_widgets.toml in state)
          desktopWidgets = {
            schema_version = 1;
            grid = {
              cell_size = 16;
              major_interval = 4;
              visible = false;
            };
            widget = [
            ];
          };
        };

        # Link the nix-monitor plugin so it is available to Noctalia v5.
        xdg.configFile."noctalia/plugins/nixos-monitor" = {
          source = inputs.noctalia-nix-monitor;
          force = true;
        };
      };
  };
}
