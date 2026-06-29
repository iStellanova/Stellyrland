{
  inputs,
  lib,
  ...
}: {
  sn.desktop = _: {
    includes = [];
  };

  flake-file.inputs.mango.url = "github:mangowm/mango/hdr";
  flake-file.inputs.scenefx-hdr = {
    url = "github:wlrfx/scenefx";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.mango.nixos = {pkgs, ...}: let
    scenefxPkg = inputs.scenefx-hdr.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      buildInputs =
        (builtins.filter (dep: !(dep ? pname && dep.pname == "wlroots")) old.buildInputs)
        ++ [pkgs.wlroots_0_20 pkgs.lcms2];
    });
    mangoPkg = inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango.override {
      wlroots_0_19 = pkgs.wlroots_0_20;
      scenefx = scenefxPkg;
    };
  in {
    imports = [inputs.mango.nixosModules.mango];

    options.desktop.mango = {
      enable = lib.mkEnableOption "Mango desktop environment";
      monitors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Monitor rule strings passed directly as monitorrule entries (e.g. \"name:DP-2,width:3440,height:1440,refresh:175,x:0,y:0,scale:1,vrr:1\").";
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
          default = [];
          description = "List of monitor outputs to pass as --screen-root flags to linux-wallpaperengine.";
        };
      };
    };

    config = {
      programs.mango = {
        enable = true;
        package = mangoPkg;
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

      services.xserver.videoDrivers = ["amdgpu"];

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];
        config.common.default = "*";
      };
    };
  };

  sn.mango.homeManager = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    scenefxPkg = inputs.scenefx-hdr.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      buildInputs =
        (builtins.filter (dep: !(dep ? pname && dep.pname == "wlroots")) old.buildInputs)
        ++ [pkgs.wlroots_0_20 pkgs.lcms2];
    });
    mangoPkg = inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango.override {
      wlroots_0_19 = pkgs.wlroots_0_20;
      scenefx = scenefxPkg;
    };
    we = osConfig.desktop.mango.wallpaperEngine;
    screenRootFlags = lib.concatMapStringsSep " " (m: "--screen-root ${m}") we.screenRoots;
    weAutostart =
      lib.optionalString (we.workshopId != "" && we.screenRoots != [])
      "sleep 3 && linux-wallpaperengine --assets-dir ${we.steamLibrary}/steamapps/common/wallpaper_engine/assets ${screenRootFlags} --fps 60 --silent ${we.steamLibrary}/steamapps/workshop/content/431960/${we.workshopId}/ &\n";
  in {
    imports =
      [inputs.mango.hmModules.mango]
      ++ [./_animations.nix ./_binds.nix ./_rules.nix];

    _module.args.inputs = lib.mkForce inputs;

    programs.zsh.initContent = lib.mkAfter ''
      cp2c() { if [[ -z "$1" ]]; then echo "Usage: cp2c <file>" >&2; return 1; fi; wl-copy < "$1"; }
      c2f() { if [[ -z "$1" ]]; then echo "Usage: create-from-clip <filename>" >&2; return 1; fi; wl-paste > "$1"; }
    '';

    wayland.windowManager.mango = {
      enable = true;
      package = mangoPkg;
      systemd.enable = true;

      autostart_sh = ''
        wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1.0
        udiskie -a -s --file-manager nautilus &
        ${weAutostart}systemctl --user restart xdg-desktop-portal-wlr
      '';

      settings =
        {
          # --- Input ---
          xkb_rules_layout = "us";
          xkb_rules_options = "caps:escape";
          numlockon = 1;
          repeat_rate = 25;
          repeat_delay = 600;
          sloppyfocus = 1;
          mouse_accel_profile = 1;
          mouse_accel_speed = 0;

          # --- Gaps & Borders ---
          borderpx = 2;
          gappih = 4;
          gappiv = 4;
          gappoh = 8;
          gappov = 8;

          # --- Decoration ---
          border_radius = 12;
          focused_opacity = 0.8;
          unfocused_opacity = 0.8;

          # --- Colors (Catppuccin Macchiato) ---
          focuscolor = "0x8aadf4ff";
          bordercolor = "0xc0c6dc33";

          # --- Blur ---
          blur = 1;
          blur_layer = 1;
          blur_optimized = 0;
          blur_params_radius = 12;
          blur_params_num_passes = 3;
          blur_params_noise = 0;
          blur_params_brightness = 0.9;
          blur_params_contrast = 1.25;
          blur_params_saturation = 1.0;

          # --- Shadows ---
          shadows = 1;
          layer_shadows = 0;
          shadow_only_floating = 1;
          shadows_size = 10;
          shadowscolor = "0x363a4fff";

          # --- Layout ---
          circle_layout = "scroller,dwindle";
          scroller_default_proportion = 0.5;
          scroller_default_proportion_single = 1.0;
          scroller_ignore_proportion_single = 0;
          scroller_focus_center = 0;
          scroller_prefer_center = 0;
          scroller_prefer_overspread = 1;
          edge_scroller_pointer_focus = 0;
          scroller_proportion_preset = "0.5,0.8,1.0";

          # --- Cursor ---
          cursor_theme = "Bibata-Modern-Ice";
          cursor_size = 16;

          # --- Overview ---
          overviewgappi = 5;
          overviewgappo = 30;

          # --- HDR ---
          hdr_depth = 2;

          # --- Misc ---
          xwayland_persistence = 1;
          focus_cross_monitor = 1;
          warpcursor = 0;
          drag_tile_to_tile = 1;

          # --- Environment ---
          env = [
            "XCURSOR_THEME,Bibata-Modern-Ice"
            "XCURSOR_SIZE,16"
            "GTK_THEME,catppuccin-macchiato-sapphire-standard"
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_QPA_PLATFORMTHEME,gtk3"
            "QT_STYLE_OVERRIDE,kvantum"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "GDK_SCALE,1.0"
            "GTK_CSD,0"
            "XDG_CURRENT_DESKTOP,mango"
            "XDG_SESSION_TYPE,wayland"
            "XDG_SESSION_DESKTOP,mango"
            "MOZ_ENABLE_WAYLAND,1"
            "ELECTRON_OZONE_PLATFORM_HINT,auto"
            "OBS_USE_EGL,1"
            "PROTON_ENABLE_WAYLAND,1"
            "AMD_VULKAN_ICD,RADV"
            "RADV_PERFTEST,nggc"
            "VK_ICD_FILENAMES,/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
          ];
        }
        // lib.optionalAttrs (osConfig.desktop.mango.monitors != []) {
          monitorrule = osConfig.desktop.mango.monitors;
        };
    };
  };
}
