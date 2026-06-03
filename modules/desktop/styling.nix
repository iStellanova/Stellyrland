{inputs, ...}: {
  # NixOS Desktop Styling Settings
  flake.modules.nixos.styling = {...}: {
    imports = [inputs.catppuccin.nixosModules.catppuccin];

    config = {
      catppuccin.enable = true;
      catppuccin.autoEnable = false;
      catppuccin.flavor = "macchiato";
      catppuccin.accent = "sapphire";
    };
  };

  # Home Manager Desktop Styling Settings
  flake.modules.homeManager.styling = {pkgs, ...}: let
    catppuccinGtk = pkgs.catppuccin-gtk.override {
      accents = ["sapphire"];
      variant = "macchiato";
    };
  in {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    config = {
      # Catppuccin home-manager configuration.
      catppuccin.enable = true;
      catppuccin.autoEnable = false;
      catppuccin.flavor = "macchiato";
      catppuccin.accent = "sapphire";

      catppuccin.kvantum.enable = true;

      # Apps handled by Noctalia - Keep these disabled in the flake to avoid conflicts.
      catppuccin.btop.enable = false;
      catppuccin.kitty.enable = false;
      catppuccin.yazi.enable = false;
      catppuccin.zsh-syntax-highlighting.enable = false;

      gtk = {
        enable = true;
        theme = {
          name = "catppuccin-macchiato-sapphire-standard";
          package = catppuccinGtk;
        };
        gtk4.theme = {
          name = "catppuccin-macchiato-sapphire-standard";
          package = catppuccinGtk;
        };

        # Icon Theme.
        iconTheme = {
          name = "Colloid-Catppuccin-Dark";
          package = pkgs.colloid-icon-theme.override {
            schemeVariants = ["catppuccin"];
          };
        };
      };

      # Qt theming — platformTheme is intentionally omitted so HM doesn't set
      # QT_QPA_PLATFORMTHEME; the Hyprland env var (gtk3) owns that.
      # style.name = "kvantum" satisfies catppuccin.kvantum's assertStyle guard.
      qt = {
        enable = true;
        style.name = "kvantum";
      };

      # Dconf GNOME Settings.
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          accent-color = "blue";
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
        kdePackages.qtstyleplugin-kvantum # Qt6 kvantum plugin (QT_STYLE_OVERRIDE=kvantum)
        libsForQt5.qtstyleplugin-kvantum # Qt5 kvantum plugin
        nwg-look
        hyprcursor
      ];
    };
  };
}
