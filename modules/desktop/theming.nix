{
  sn,
  inputs,
  ...
}: {
  sn.desktop = {includes = [sn.theming];};

  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.theming.nixos = {...}: {
    imports = [inputs.catppuccin.nixosModules.catppuccin];

    catppuccin.enable = true;
    catppuccin.autoEnable = true;
    catppuccin.flavor = "macchiato";
    catppuccin.accent = "sapphire";
    catppuccin.tty.enable = false;
  };

  sn.theming.homeManager = {
    pkgs,
    lib,
    ...
  }: let
    catppuccinGtk = pkgs.catppuccin-gtk.override {
      accents = ["sapphire"];
      variant = "macchiato";
    };
  in {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    config = lib.mkMerge [
      {
        catppuccin.enable = pkgs.stdenv.hostPlatform.isLinux;
        catppuccin.autoEnable = false;
        catppuccin.flavor = "macchiato";
        catppuccin.accent = "sapphire";
      }
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        catppuccin.kvantum.enable = true;

        catppuccin.bat.enable = true;

        # Apps handled by Noctalia — keep disabled here to avoid conflicts.
        catppuccin.btop.enable = false;
        catppuccin.kitty.enable = false;
        catppuccin.yazi.enable = false;
        catppuccin.zsh-syntax-highlighting.enable = false;

        gtk = {
          enable = true;
          theme = {
            name = lib.mkForce "catppuccin-macchiato-sapphire-standard";
            package = lib.mkForce catppuccinGtk;
          };
          gtk4.theme = {
            name = lib.mkForce "catppuccin-macchiato-sapphire-standard";
            package = lib.mkForce catppuccinGtk;
          };
          iconTheme = {
            name = lib.mkForce "Colloid-Catppuccin-Dark";
            package = lib.mkForce (pkgs.colloid-icon-theme.override {
              schemeVariants = ["catppuccin"];
            });
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
      })
    ];
  };
}
