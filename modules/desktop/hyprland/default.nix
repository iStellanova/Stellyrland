{
  inputs,
  lib,
  ...
}: {
  den.aspects.hyprland.nixos = {pkgs, ...}: {
    imports = [inputs.hyprland.nixosModules.default];

    options.desktop.hyprland = {
      enable = lib.mkEnableOption "Hyprland desktop environment";
      monitorConfig = lib.mkOption {
        type = lib.types.str;
        default = ''hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })'';
        description = "Lua monitor configuration for the main Hyprland session.";
      };
      greetdMonitorConfig = lib.mkOption {
        type = lib.types.str;
        default = ''hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })'';
        description = "Lua monitor configuration for the greetd login session. Should use plain SDR (no cm = hdr) to avoid HDR rendering issues in the greeter.";
      };
      wallpaperEngine = {
        steamLibrary = lib.mkOption {
          type = lib.types.str;
          default = "/ExtraDisk/SteamLibrary";
          description = "Path to the Steam library containing wallpaper_engine and workshop content.";
        };
        workshopId = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Workshop item ID to pass to linux-wallpaperengine. Empty disables it.";
        };
      };
    };

    config = {
      programs.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

      environment.systemPackages = with pkgs; [
        wl-clipboard
        file-roller
        libnotify
        udiskie
        linux-wallpaperengine
        xhost
        xauth
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.xserver.videoDrivers = ["amdgpu"];
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        extraConfig = {
          pipewire."99-lowlatency" = {
            "context.properties"."default.clock.min-quantum" = 512;
            "context.modules" = [
              {
                name = "libpipewire-module-rt";
                flags = ["ifexists" "nofail"];
                args = {
                  "nice.level" = -15;
                  "rt.prio" = 88;
                  "rt.time.soft" = 200000;
                  "rt.time.hard" = 200000;
                };
              }
            ];
          };
          pipewire-pulse."99-lowlatency" = {
            "pulse.properties" = {
              "server.address" = ["unix:native"];
              "pulse.min.req" = "512/48000";
              "pulse.min.quantum" = "512/48000";
              "pulse.min.frag" = "512/48000";
              "pulse.flat-volumes" = false;
            };
          };
          client."99-lowlatency"."stream.properties" = {
            "node.latency" = "512/48000";
            "resample.quality" = 4;
          };
        };
        wireplumber = {
          enable = true;
          extraConfig = {
            "10-ignore-vols" = {
              "monitor.alsa.rules" = [
                {
                  matches = [{"media.class" = "Audio/Source";}];
                  actions = {
                    update-props = {
                      "node.ignore-session-volume" = true;
                    };
                  };
                }
              ];
            };
          };
        };
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config.common.default = "*";
      };
    };
  };

  den.aspects.hyprland.homeManager = {
    pkgs,
    lib,
    osConfig,
    ...
  }: {
    imports = [
      inputs.hyprland.homeManagerModules.default
      ./_animations.nix
      ./_binds.nix
      ./_rules.nix
    ];

    _module.args.inputs = inputs;

    programs.zsh.shellAliases = {
      screenoff = "HYPRLAND_INSTANCE_SIGNATURE=$(basename /run/user/$(id -u)/hypr/*/) hyprctl eval \"hl.dispatch(hl.dsp.dpms({ action = 'off' }))\"";
      screenon = "HYPRLAND_INSTANCE_SIGNATURE=$(basename /run/user/$(id -u)/hypr/*/) hyprctl eval \"hl.dispatch(hl.dsp.dpms({ action = 'on' }))\"";
    };

    programs.zsh.initContent = lib.mkAfter ''
      cp2c() { if [[ -z "$1" ]]; then echo "Usage: cp2c <file>" >&2; return 1; fi; wl-copy < "$1"; }
      c2f() { if [[ -z "$1" ]]; then echo "Usage: create-from-clip <filename>" >&2; return 1; fi; wl-paste > "$1"; }
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      xwayland.enable = true;
      systemd.enable = true;

      settings = {
        env = [
          {_args = ["HYPRCURSOR_THEME" "Bibata-Modern-Ice-Hypr"];}
          {_args = ["HYPRCURSOR_SIZE" "16"];}
          {_args = ["XCURSOR_THEME" "Bibata-Modern-Ice"];}
          {_args = ["XCURSOR_SIZE" "16"];}
          {_args = ["GTK_THEME" "catppuccin-macchiato-sapphire-standard"];}
          {_args = ["QT_QPA_PLATFORM" "wayland;xcb"];}
          {_args = ["QT_QPA_PLATFORMTHEME" "gtk3"];}
          {_args = ["QT_STYLE_OVERRIDE" "kvantum"];}
          {_args = ["QT_WAYLAND_DISABLE_WINDOWDECORATION" "1"];}
          {_args = ["GDK_SCALE" "1.0"];}
          {_args = ["GTK_CSD" "0"];}
          {_args = ["XDG_CURRENT_DESKTOP" "Hyprland"];}
          {_args = ["XDG_SESSION_TYPE" "wayland"];}
          {_args = ["XDG_SESSION_DESKTOP" "Hyprland"];}
          {_args = ["MOZ_ENABLE_WAYLAND" "1"];}
          {_args = ["ELECTRON_OZONE_PLATFORM_HINT" "auto"];}
          {_args = ["OBS_USE_EGL" "1"];}
          {_args = ["PROTON_ENABLE_WAYLAND" "1"];}
          {_args = ["AMD_VULKAN_ICD" "RADV"];}
          {_args = ["RADV_PERFTEST" "nggc"];}
          {_args = ["VK_ICD_FILENAMES" "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"];}
        ];

        config = {
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
            col = {
              active_border = {
                colors = ["rgb(8aadf4)" "rgb(363a4f)"];
                angle = 45;
              };
              inactive_border = "rgba(c0c6dc33)";
            };
            resize_on_border = true;
            allow_tearing = false;
            layout = "scrolling";
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
          cursor = {
            sync_gsettings_theme = true;
            warp_on_change_workspace = false;
            no_hardware_cursors = false;
          };
          render = {
            direct_scanout = false;
            cm_enabled = true;
            cm_auto_hdr = 0;
          };
          scrolling = {
            column_width = 0.5;
            fullscreen_on_one_column = true;
            follow_focus = true;
            focus_fit_method = 1;
          };
          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
          };
          xwayland = {
            force_zero_scaling = true;
          };
        };
      };

      # smw requires runtime require(); startup needs arbitrary exec-once — both must stay in extraConfig.
      extraConfig = let
        we = osConfig.desktop.hyprland.wallpaperEngine;
        wallpaperCmd = lib.optionalString (we.workshopId != "") ''
          hl.exec_cmd([[sleep 3 && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets --screen-root DP-2 --screen-root DP-3 --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/]])
        '';
      in ''
                  ${osConfig.desktop.hyprland.monitorConfig}

                  hl.on("hyprland.start", function()
                      hl.exec_cmd("dbus-update-activation-environment --systemd --all")
                      hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
                      hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0")
                      hl.exec_cmd("udiskie -a -s --file-manager nautilus")
        ${wallpaperCmd}hl.exec_cmd("systemctl --user restart xdg-desktop-portal-hyprland")
                  end)
      '';
    };
  };
}
