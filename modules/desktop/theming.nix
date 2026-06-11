{
  sn,
  inputs ? {},
  ...
}: {
  sn.desktop = {includes = [sn.theming];};

  flake-file.inputs.catppuccin.url = "github:catppuccin/nix";

  sn.theming.nixos = {...}: {
    imports =
      if inputs ? catppuccin
      then [inputs.catppuccin.nixosModules.catppuccin]
      else [];

    catppuccin.enable = true;
    catppuccin.autoEnable = false;
    catppuccin.flavor = "macchiato";
    catppuccin.accent = "sapphire";
  };

  sn.theming.homeManager = {pkgs, ...}: let
    catppuccinGtk = pkgs.catppuccin-gtk.override {
      accents = ["sapphire"];
      variant = "macchiato";
    };
  in {
    imports =
      if inputs ? catppuccin
      then [inputs.catppuccin.homeModules.catppuccin]
      else [];

    catppuccin.enable = true;
    catppuccin.autoEnable = false;
    catppuccin.flavor = "macchiato";
    catppuccin.accent = "sapphire";

    catppuccin.kvantum.enable = true;

    # Apps handled by Noctalia — keep disabled here to avoid conflicts.
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
      iconTheme = {
        name = "Colloid-Catppuccin-Dark";
        package = pkgs.colloid-icon-theme.override {
          schemeVariants = ["catppuccin"];
        };
      };
    };

    # Qt theming — platformTheme intentionally omitted so HM doesn't set
    # QT_QPA_PLATFORMTHEME; the Hyprland env var (gtk3) owns that.
    # style.name = "kvantum" satisfies catppuccin.kvantum's assertStyle guard.
    qt = {
      enable = true;
      style.name = "kvantum";
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "blue";
        icon-theme = "Colloid-Catppuccin-Dark";
        cursor-theme = "Bibata-Modern-Ice";
        cursor-size = 16;
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 16;
    };

    home.packages = with pkgs; [
      kdePackages.qtstyleplugin-kvantum
      libsForQt5.qtstyleplugin-kvantum
      nwg-look
    ];
  };
}
