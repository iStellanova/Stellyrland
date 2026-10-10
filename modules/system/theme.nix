{ inputs, ... }:
{
  pins.catppuccin = {
    url = "https://github.com/catppuccin/nix";
    follows.nixpkgs = "nixpkgs";
  };

  modules.nixos.catppuccin = { ... }: {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "macchiato";
      accent = "sapphire";
      tty.enable = false;
    };
  };

  modules.homeManager.catppuccin = { pkgs, lib, ... }:
    let
      catppuccinGtk = pkgs.catppuccin-gtk.override {
        accents = [ "sapphire" ];
        variant = "macchiato";
      };
    in
    {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];

      config = lib.mkMerge [
        {
          catppuccin = {
            enable = true;
            autoEnable = false;
            flavor = "macchiato";
            accent = "sapphire";
            bat.enable = true;
            kitty.enable = true;
            eza.enable = true;
            fzf.enable = true;
            btop.enable = true;
            yazi.enable = true;
            zsh-syntax-highlighting.enable = true;
            cava.enable = true;
          };
        }
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          catppuccin = {
            kvantum.enable = true;
          };

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
              package = lib.mkForce (
                pkgs.colloid-icon-theme.override {
                  schemeVariants = [ "catppuccin" ];
                }
              );
            };
          };

          # style.name = "kvantum" satisfies catppuccin.kvantum's assertStyle guard.
          qt = {
            enable = true;
            style.name = "kvantum";
          };

          dconf.settings = {
            "org/gnome/desktop/interface" = {
              color-scheme = "prefer-dark";
              accent-color = "blue";
              clock-format = "12h";
              icon-theme = "Colloid-Catppuccin-Dark";
              cursor-theme = "Bibata-Modern-Ice";
              cursor-size = 16;
            };
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
