{ config, lib, pkgs, ... }:

let
  cfg = config.aspects.desktop.hyprland;
in
{
  options.aspects.desktop.hyprland.enable = lib.mkEnableOption "Hyprland desktop environment";

  config = lib.mkIf cfg.enable {
    # NixOS level config
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

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = let
            wallpaper = ../../../assets/login-wallpaper.png;
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
        window { background-color: transparent; }
        #container, .container, #clock, popover contents {
          background-color: rgba(30, 30, 46, 0.55);
          border-radius: 16px;
          padding: 24px;
          box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
          border: 1px solid rgba(180, 190, 254, 0.4);
        }
        #clock { font-size: 32px; margin-bottom: 20px; padding: 12px 24px; }
        popover contents { padding: 8px; border-radius: 12px; }
        button { background-color: #b4befe; color: #11111b; border-radius: 8px; font-weight: bold; }
        button:hover { background-color: #cdd6f4; }
        entry {
          background-color: rgba(49, 50, 68, 0.6);
          color: #cdd6f4;
          border: 1px solid #45475a;
          border-radius: 8px;
          caret-color: #b4befe;
        }
      '';
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    # Home Manager level config
    home-manager.users.stellanova = {
      imports = [
        ./binds.nix
        ./rules.nix
      ];

      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        systemd.enable = true;

        settings = {
          monitor = [
            "DP-2, 3440x1440@175, 1440x541, 1, bitdepth, 10, sdrbrightness, 1.2, sdrsaturation, 0.98"
            "DP-3, 2560x1440@100, 0x0, 1, transform, 1, bitdepth, 10, sdrbrightness, 1.2, sdrsaturation, 0.98"
            ", preferred, auto, 1"
          ];

          workspace = [
            "1, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true, default:true"
            "2, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
            "3, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
            "4, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
            "5, monitor:desc:Samsung Electric Company Odyssey G85SB H1AK500000, persistent:true"
          ];

          "exec-once" = [
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DISPLAY"
            "dbus-update-activation-environment --systemd --all"
            "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            "systemctl --user start hyprpolkitagent"
            "gnome-keyring-daemon --start --components=secrets"
            "mprisence"
            "udiskie -a -s --file-manager nautilus"
            "wl-paste --type text --watch cliphist store"
            "wl-paste --type image --watch cliphist store"
            "noctalia-shell"
            "systemctl --user restart xdg-desktop-portal-hyprland"
            "qs-hyprview"
            "sleep 1 && cmd=$(ps aux | grep '[l]inux-wallpaperengine' | awk '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=""; print $0}'); pkill linux-wallpaperengine; eval $cmd &"
          ];

          env = [
            "HYPRCURSOR_THEME, Bibata-Modern-Ice-Hypr"
            "HYPRCURSOR_SIZE, 16"
            "XCURSOR_THEME, Bibata-Modern-Ice"
            "XCURSOR_SIZE, 16"
            "QT_QPA_PLATFORM, wayland;xcb"
            "QT_QPA_PLATFORMTHEME, gtk3"
            "QT_STYLE_OVERRIDE, kvantum"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
            "QT_AUTO_SCREEN_SCALE_FACTOR, 1.25"
            "GDK_SCALE, 1.0"
            "GTK_THEME, catppuccin-macchiato-flamingo-standard"
            "GTK_CSD, 0"
            "XDG_CURRENT_DESKTOP, Hyprland"
            "XDG_SESSION_TYPE, wayland"
            "XDG_SESSION_DESKTOP, Hyprland"
            "MOZ_ENABLE_WAYLAND, 1"
            "ELECTRON_OZONE_PLATFORM_HINT, auto"
            "OBS_USE_EGL, 1"
            "PROTON_ENABLE_WAYLAND, 1"
            "PROTON_ENABLE_HDR, 1"
          ];

          input = {
            kb_layout = "us";
            kb_options = "caps:escape";
            numlock_by_default = true;
            follow_mouse = 1;
            sensitivity = 0;
            accel_profile = "flat";
          };

          general = {
            gaps_in = 4;
            gaps_out = 8;
            border_size = 2;
            "col.active_border" = "rgb(8aadf4) rgb(363a4f) 45deg";
            "col.inactive_border" = "rgba(c0c6dc33)";
            resize_on_border = true;
            allow_tearing = false;
            layout = "dwindle";
          };

          decoration = {
            rounding = 12;
            active_opacity = 0.8;
            inactive_opacity = 0.8;
            fullscreen_opacity = 1.0;
            shadow = {
              range = 10;
              render_power = 4;
              sharp = false;
              color = "rgb(363a4f)";
              color_inactive = "rgba(0,0,0,0)";
            };
            blur = {
              enabled = true;
              size = 12;
              passes = 3;
              noise = 0;
              brightness = 0.9;
              contrast = 1.25;
              vibrancy = 1;
              xray = false;
              new_optimizations = true;
              popups = true;
              popups_ignorealpha = 0.1;
              special = false;
            };
          };

          animations = {
            enabled = true;
            bezier = [
              "md3_decel,     0.05, 0.7,  0.1,  1"
              "md3_accel,     0.3,  0,    0.8,  0.15"
              "hyprnostretch, 0.05, 0.9,  0.1,  1.0"
              "menu_decel,    0.1,  1,    0,    1"
              "menu_accel,    0.38, 0.04, 1,    0.07"
              "easeOutExpo,   0.16, 1,    0.3,  1"
              "softAcDecel,   0.26, 0.26, 0.15, 1"
            ];
            animation = [
              "windows,    1, 3,   md3_decel,     popin 60%"
              "windowsIn,  1, 3,   hyprnostretch, popin 40%"
              "windowsOut, 1, 3,   md3_accel,     popin 60%"
              "fade,         1, 3,   md3_decel"
              "layersIn,     1, 3,   menu_decel, popin"
              "layersOut,    1, 1.6, menu_accel"
              "fadeLayersIn, 1, 2,   menu_decel"
              "workspaces,       1, 5, easeOutExpo, slidefade 50%"
              "specialWorkspace, 1, 3, md3_decel,   slidefadevert 15%"
              "border,      1, 10,  default"
              "borderangle, 1, 100, softAcDecel, once"
            ];
          };

          cursor = {
            sync_gsettings_theme = true;
            warp_on_change_workspace = false;
            no_hardware_cursors = false;
          };

          render.direct_scanout = false;
          dwindle = { pseudotile = true; preserve_split = true; };
          misc = { force_default_wallpaper = 0; disable_hyprland_logo = true; };
          xwayland.force_zero_scaling = true;
        };
      };
    };
  };
}
