{
  sn,
  inputs ? {},
  ...
}: {
  sn.desktop = {includes = [sn.flatpak];};

  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";

  sn.flatpak.nixos = {...}: {
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
