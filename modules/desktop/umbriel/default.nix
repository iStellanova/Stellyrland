{
  flake-file.inputs.umbriel = {
    # TODO(umbriel): drop this input once nixpkgs provides a Home Manager module.
    # Umbriel's package requires its patched SceneFX submodule.
    url = "git+https://github.com/noctalia-dev/umbriel?submodules=1";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.umbriel =
    {
      inputs,
      host,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./_options.nix
        inputs.umbriel.nixosModules.default
      ]
      ++ lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/umbriel"
        ];
      };

      programs.umbriel = {
        enable = true;
        portalPackage = pkgs.xdg-desktop-portal-umbriel;
      };

      hardware.graphics.enable32Bit = true;
      environment.systemPackages = with pkgs; [
        wl-clipboard
        udiskie
        linux-wallpaperengine
      ];

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
        config.umbriel.default = [
          "umbriel"
          "gtk"
        ];
      };
    };

  flake.modules.homeManager.umbriel =
    {
      inputs,
      ...
    }:
    {
      imports = [
        inputs.umbriel.homeModules.default
        ./_animations.nix
        ./_config.nix
        ./_env.nix
        ./_autostart.nix
        ./_binds.nix
        ./_rules.nix
      ];

      programs.umbriel.enable = true;
    };
}
