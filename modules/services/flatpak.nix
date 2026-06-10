{inputs ? {}, ...}: {
  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";

  den.aspects.flatpak.nixos = {...}: {
    imports =
      if inputs ? nix-flatpak
      then [inputs.nix-flatpak.nixosModules.nix-flatpak]
      else [];

    services.flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [
        "org.vinegarhq.Sober"
      ];
    };
  };
}
