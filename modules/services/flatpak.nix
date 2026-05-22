_: {
  config = {
    # NixOS Flatpak Settings
    flake.modules.nixos.default = {
      config,
      lib,
      ...
    }: {
      options.aspects.services.flatpak.enable = lib.mkEnableOption "Flatpak sandboxed application support";

      config = lib.mkIf config.aspects.services.flatpak.enable {
        services.flatpak = {
          enable = true;
          update.onActivation = true;
          packages = [
            "org.vinegarhq.Sober"
          ];
        };
      };
    };
  };
}
