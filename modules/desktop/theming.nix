{ inputs, ... }:
{
  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.theming = { ... }: {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];

    catppuccin.enable = true;
    catppuccin.autoEnable = true;
    catppuccin.flavor = "macchiato";
    catppuccin.accent = "sapphire";
    catppuccin.tty.enable = false;

    nixpkgs.overlays = [
      (final: prev: {
        python3 = prev.python3.override {
          packageOverrides = _: pyPrev: {
            # TODO: revisit — catppuccin's optional matplotlib integration calls
            # a matplotlib internal (mpl.style.core.read_style_directory) that
            # was removed upstream, breaking this package's own test suite even
            # though catppuccin-gtk (the only consumer here) never touches that
            # codepath. Safe to drop once nixpkgs bumps catppuccin past this.
            catppuccin = pyPrev.catppuccin.overrideAttrs (_: {
              doCheck = false;
              doInstallCheck = false;
            });
          };
        };
        python3Packages = final.python3.pkgs;
      })
    ];
  };

  flake.modules.homeManager.theming =
    {
      pkgs,
      lib,
      ...
    }:
    let
      catppuccinGtk =
        (pkgs.catppuccin-gtk.override {
          accents = [ "sapphire" ];
          variant = "macchiato";
        }).overrideAttrs
          (old: {
            # TODO: revisit — build.py's arg parser passes type=bool alongside
            # argparse.BooleanOptionalAction, which Python 3.12+ rejects
            # outright (previously silently ignored). The action already
            # implies bool, so dropping type= changes nothing else. Safe to
            # drop once nixpkgs bumps catppuccin-gtk past this.
            postPatch = (old.postPatch or "") + ''
              sed -i '/type=bool,/d' sources/build/args.py
            '';
          });
    in
    {
      imports = [ inputs.catppuccin.homeModules.catppuccin ];

      config = lib.mkMerge [
        {
          catppuccin.enable = true;
          catppuccin.autoEnable = false;
          catppuccin.flavor = "macchiato";
          catppuccin.accent = "sapphire";

          catppuccin.bat.enable = true;
        }
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          # Noctalia owns these on Linux; catppuccin manages them on Darwin instead.
          catppuccin.kitty.enable = true;
          catppuccin.eza.enable = true;
          catppuccin.fzf.enable = true;
          catppuccin.btop.enable = true;
          catppuccin.yazi.enable = true;
          catppuccin.zsh-syntax-highlighting.enable = true;
          catppuccin.cava.enable = true;
        })
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          catppuccin.kvantum.enable = true;

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
              package = lib.mkForce (
                pkgs.colloid-icon-theme.override {
                  schemeVariants = [ "catppuccin" ];
                }
              );
            };
          };

          # platformTheme omitted — Hyprland env (gtk3) owns QT_QPA_PLATFORMTHEME.
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
            enable = true;
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
