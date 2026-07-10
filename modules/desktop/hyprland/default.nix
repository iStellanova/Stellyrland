{
  inputs,
  sn,
  lib,
  ...
}:
{
  sn.desktop = { host, ... }: {
    includes = if host.class == "nixos" then [ sn.hyprland ] else [ ];
  };

  # Hyprland follows scroll-overview's own flake input rather than being pinned independently —
  # the plugin has no stable ABI across Hyprland versions, so it must be built against exactly
  # the Hyprland it'll run inside. See _overview.nix for details.
  flake-file.inputs.hyprsplit = {
    url = "github:shezdy/hyprsplit";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-file.inputs.scroll-overview = {
    url = "github:myamusashi/hyprland-scroll-overview";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.hyprland.nixos = { pkgs, ... }: {
    imports = [ inputs.scroll-overview.inputs.hyprland.nixosModules.default ];

    options.desktop.hyprland = {
      monitors = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
        default = [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          }
        ];
        description = "Monitor configurations passed to hl.monitor().";
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
        screenRoots = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "List of monitor outputs to pass as --screen-root flags to linux-wallpaperengine.";
        };
      };
      hyprsplit = {
        monitorPriority = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Monitor output names in priority order for hyprsplit workspace assignment. Empty omits the priority call.";
        };
        numWorkspaces = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Number of workspaces hyprsplit creates per monitor.";
        };
      };
    };

    config = {
      nix.settings.substituters = [ "https://hyprland.cachix.org" ];
      nix.settings.trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];

      programs.hyprland = {
        enable = true;
        package =
          inputs.scroll-overview.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.scroll-overview.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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

      hardware.graphics.enable32Bit = true;

      services.xserver.videoDrivers = [ "amdgpu" ];

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = [
          "hyprland"
          "gtk"
        ];
      };
    };
  };

  sn.hyprland.homeManager =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    let
      lua = lib.generators.mkLuaInline;
      we = osConfig.desktop.hyprland.wallpaperEngine;
      screenRootFlags = lib.concatMapStringsSep " " (m: "--screen-root ${m}") we.screenRoots;
    in
    {
      imports = [
        inputs.scroll-overview.inputs.hyprland.homeManagerModules.default
      ]
      ++ [
        ./_animations.nix
        ./_binds.nix
        ./_cursor.nix
        ./_overview.nix
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
        package =
          inputs.scroll-overview.inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        xwayland.enable = true;
        systemd.enable = true;
        portalPackage = null;

        settings = {
          monitor = osConfig.desktop.hyprland.monitors;

          on =
            let
              weCmd =
                lib.optionalString (we.workshopId != "" && we.screenRoots != [ ])
                  "hl.exec_cmd([[sleep 3 && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets ${screenRootFlags} --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/]])\n    ";
            in
            {
              _args = [
                "hyprland.start"
                (lua ''
                  function()
                    hl.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0")
                    hl.exec_cmd("udiskie -a -s --file-manager nautilus")
                    ${weCmd}hl.exec_cmd("systemctl --user restart xdg-desktop-portal-hyprland")
                  end'')
              ];
            };

          env =
            {
              HYPRCURSOR_THEME = "Bibata-Modern-Ice";
              HYPRCURSOR_SIZE = "16";
              XCURSOR_THEME = "Bibata-Modern-Ice";
              XCURSOR_SIZE = "16";
              AQ_MGPU_NO_EXPLICIT = "1";
              AQ_NO_MODIFIERS = "1";
              GTK_THEME = "catppuccin-macchiato-sapphire-standard";
              QT_QPA_PLATFORM = "wayland;xcb";
              QT_QPA_PLATFORMTHEME = "gtk3";
              QT_STYLE_OVERRIDE = "kvantum";
              QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
              GDK_SCALE = "1.0";
              GTK_CSD = "0";
              XDG_CURRENT_DESKTOP = "Hyprland";
              XDG_SESSION_TYPE = "wayland";
              XDG_SESSION_DESKTOP = "Hyprland";
              MOZ_ENABLE_WAYLAND = "1";
              ELECTRON_OZONE_PLATFORM_HINT = "auto";
              OBS_USE_EGL = "1";
              PROTON_ENABLE_WAYLAND = "1";
              AMD_VULKAN_ICD = "RADV";
              RADV_PERFTEST = "nggc";
              VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json";
            }
            |> lib.mapAttrsToList (
              name: value: {
                _args = [
                  name
                  value
                ];
              }
            );

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
                  colors = [
                    "rgb(8aadf4)"
                    "rgb(363a4f)"
                  ];
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
      };
    };
}
