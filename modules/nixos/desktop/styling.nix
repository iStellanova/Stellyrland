{ config, lib, identity, ... }:

{
  options.aspects.desktop.styling.enable = lib.mkEnableOption "Desktop styling (GTK, QT, Cursors)" // { default = true; };

  config = lib.mkIf config.aspects.desktop.styling.enable {
    # Global Catppuccin configuration for the system.
    # This provides a base theme for system-level toolkits.
    catppuccin.flavor = "macchiato";
    catppuccin.accent = "flamingo";

    home-manager.users.${identity.name} = { pkgs, ... }: {
      # Catppuccin home-manager configuration.
      catppuccin.flavor = "macchiato";
      catppuccin.accent = "flamingo";

      # Hybrid Theming Strategy:
      # We enable the Catppuccin flake for core toolkits (GTK/QT) to ensure
      # consistency in complex apps, but keep it DISABLED for terminal/shell
      # apps (Kitty, Btop, Yazi, Zsh) to allow Noctalia to handle them dynamically.
      catppuccin.kvantum.enable = true;

      # Apps handled by Noctalia - Keep these disabled in the flake to avoid conflicts.
      catppuccin.btop.enable = false;
      catppuccin.kitty.enable = false;
      catppuccin.yazi.enable = false;
      catppuccin.zsh-syntax-highlighting.enable = false;

      gtk = {
        enable = true;
        theme = {
          name = "catppuccin-macchiato-flamingo-standard";
          package = pkgs.catppuccin-gtk.override {
            accents = [ "flamingo" ];
            variant = "macchiato";
          };
        };
        gtk4.theme = null;

        # Icon Theme.
        iconTheme = {
          name = "Colloid-Catppuccin-Dark";
          package = pkgs.colloid-icon-theme.override {
            schemeVariants = [ "catppuccin" ];
          };
        };
      };

      # Specify QT theme.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      # Dconf GNOME Settings.
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          icon-theme = "Colloid-Catppuccin-Dark";
          cursor-theme = "Bibata-Modern-Ice";
          cursor-size = 16;
        };
      };

      # Cursor configuration.
      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        hyprcursor.enable = true;
        hyprcursor.size = 16;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 16;
      };

      # Additional packages for cursor and desktop management.
      home.packages = with pkgs; [
        kdePackages.qtstyleplugin-kvantum
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct
        nwg-look
        bibata-cursors
        hyprcursor
      ];
    };
  };
}
