{inputs, ...}: {
  # NixOS Flatpak Settings
  flake.modules.nixos.flatpak = {...}: {
    imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];

    config = {
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
