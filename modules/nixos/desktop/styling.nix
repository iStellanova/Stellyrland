{ config, lib, identity, ... }:

{
  options.aspects.desktop.styling.enable = lib.mkEnableOption "Desktop styling (GTK, QT, Cursors)" // { default = true; };

  config = lib.mkIf config.aspects.desktop.styling.enable {
    home-manager.users.${identity.name} = { config, pkgs, ... }: {
      gtk = {
        enable = true;

        # GTK Theme.
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

      # Specify GTK theme.
      home.sessionVariables.GTK_THEME = "catppuccin-macchiato-flamingo-standard";

      # Specify QT theme.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      # Asset Distribution:
      # Manually link GTK 4.0 and Kvantum assets. This is required to ensure
      # a consistent Catppuccin theme across all toolkits (libadwaita, Qt, etc.)
      # since many modern apps ignore standard GTK_THEME variables.
      xdg.configFile = {
        "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";

        # Distributes the Kvantum theme for Qt applications.
        "Kvantum/kvantum.kvconfig".text = "[General]\ntheme=catppuccin-macchiato-flamingo";
        "Kvantum/catppuccin-macchiato-flamingo".source = "${pkgs.catppuccin-kvantum.override {
          variant = "macchiato";
          accent = "flamingo";
        }}/share/Kvantum/catppuccin-macchiato-flamingo";

        # Ensures kvantum is specified.
        "qt5ct/qt5ct.conf".text = "[Appearance]\nstyle=kvantum";
        "qt6ct/qt6ct.conf".text = "[Appearance]\nstyle=kvantum";
      };

      # Dconf GNOME Settings after the above is set.
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "catppuccin-macchiato-flamingo-standard";
          icon-theme = "Colloid-Catppuccin-Dark";
          cursor-theme = "Bibata-Modern-Ice";
          cursor-size = 16;
        };
      };

      # Cursor stuff
      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        hyprcursor.enable = true;
        hyprcursor.size = 16;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 16;
      };

      # Packages for cursor and theme.
      home.packages = with pkgs; [
        (catppuccin-kvantum.override {
          variant = "macchiato";
          accent = "flamingo";
        })
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
