_: {
  flake-file.inputs.hyprsplit = {
    url = "github:shezdy/hyprsplit";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # Source only, no flake eval — their flake.nix pins its own independent Hyprland and
  # would conflict with pkgs.hyprland. We build it ourselves in _overview.nix instead.
  flake-file.inputs.scroll-overview = {
    url = "github:yayuuu/hyprland-scroll-overview";
    flake = false;
  };

  flake.modules.nixos.hyprland =
    {
      lib,
      pkgs,
      host,
      ...
    }:
    {
      imports = [
        ./_options.nix
      ]
      ++ lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/hyprland"
        ];
      };
      config = {
        programs.hyprland.enable = true;
        hardware.graphics.enable32Bit = true;
        environment.systemPackages = with pkgs; [
          wl-clipboard
          file-roller
          libnotify
          udiskie
          linux-wallpaperengine
        ];

        # host.graphics ("amd"/"intel"/"nvidia") picks the driver.
        services.xserver.videoDrivers =
          if host.graphics == "amd" then
            [ "amdgpu" ]
          else if host.graphics == "nvidia" then
            [ "nvidia" ]
          else
            [ ];

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

  flake.modules.homeManager.hyprland =
    {
      lib,
      osConfig,
      ...
    }:
    {
      imports = [
        ./_animations.nix
        ./_autostart.nix
        ./_binds.nix
        ./_config.nix
        ./_cursor.nix
        ./_env.nix
        ./_overview.nix
        ./_rules.nix
      ];

      _module.args.lua = lib.generators.mkLuaInline;
      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        xwayland.enable = true;
        systemd.enable = true;
        portalPackage = null;

        settings = {
          monitor = osConfig.desktop.hyprland.monitors;
        };
      };
    };
}
