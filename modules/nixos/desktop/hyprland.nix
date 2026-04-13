{ config, pkgs, ... }:

{
  programs.hyprland.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
    ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.displayManager.sddm.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = let
          # Import the wallpaper into the Nix store so the 'greeter' user can read it
          wallpaper = ../../../login-wallpaper.png;
          greetdHyprConfig = pkgs.writeText "greetd-hyprland.conf" ''
            monitor=DP-2, 3440x1440@175, 1440x541, 1, bitdepth, 10, sdrbrightness, 1.2, sdrsaturation, 0.98
            monitor=DP-3, 2560x1440@100, 0x0, 1, transform, 1, bitdepth, 10, sdrbrightness, 1.2, sdrsaturation, 0.98
            monitor=, preferred, auto, 1
            
            misc {
              disable_hyprland_logo = true
              disable_splash_rendering = true
              force_default_wallpaper = 0
            }

            decoration {
              blur {
                enabled = true
                size = 10
                passes = 3
                new_optimizations = true
                ignore_opacity = true
                vibrancy = 0.1696
              }
            }

            layerrule = blur on, match:namespace regreet
            layerrule = ignore_alpha 0.5, match:namespace regreet

            env = XCURSOR_THEME,Bibata-Modern-Ice
            env = XCURSOR_SIZE,16
            env = HYPRCURSOR_THEME,Bibata-Modern-Ice
            env = HYPRCURSOR_SIZE,16
            env = XCURSOR_PATH,${pkgs.bibata-cursors}/share/icons
            env = HYPRLAND_STARTED_WITH_HYPRLAND_START, 1
            
            exec-once = ${config.programs.hyprland.package}/bin/hyprctl setcursor Bibata-Modern-Ice 16
            exec-once = ${pkgs.swaybg}/bin/swaybg -o \* -i ${wallpaper} -m fill
            exec-once = ${pkgs.regreet}/bin/regreet; ${config.programs.hyprland.package}/bin/hyprctl dispatch exit
          '';
        in "${config.programs.hyprland.package}/bin/Hyprland --config ${greetdHyprConfig}";
        user = "greeter";
      };
    };
  };

  programs.regreet = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
    };
    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
    extraCss = ''
      window {
        background-color: transparent;
      }

      #container, .container, #clock, popover contents {
        background-color: rgba(30, 30, 46, 0.55); /* Opacity must be higher than ignorealpha (0.5) */
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
        border: 1px solid rgba(180, 190, 254, 0.4); /* Lavender border with transparency */
      }

      #clock {
        font-size: 32px;
        margin-bottom: 20px;
        padding: 12px 24px;
      }

      popover contents {
        padding: 8px;
        border-radius: 12px;
      }

      button {
        background-color: #b4befe; /* Lavender */
        color: #11111b; /* Crust */
        border-radius: 8px;
        font-weight: bold;
      }

      button:hover {
        background-color: #cdd6f4; /* Text */
      }

      entry {
        background-color: rgba(49, 50, 68, 0.6); /* Surface0 with transparency */
        color: #cdd6f4; /* Text */
        border: 1px solid #45475a; /* Surface1 */
        border-radius: 8px;
        caret-color: #b4befe; /* Lavender */
      }
    '';
  };

  environment.systemPackages = [
    pkgs.greetd
    pkgs.regreet
    pkgs.bibata-cursors
  ];

  programs.gamescope.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk 
      pkgs.xdg-desktop-portal-hyprland 
    ];
    config.common.default = "*";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
}
