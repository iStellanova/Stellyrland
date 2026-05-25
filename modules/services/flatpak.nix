{inputs, ...}: {
  # NixOS Flatpak Settings
  flake.modules.nixos.flatpak = {
    config,
    lib,
    ...
  }: {
    imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];

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
}
