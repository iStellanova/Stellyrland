{
  sn,
  inputs,
  ...
}:
{
  sn.desktop = {
    includes = [ sn.flatpak ];
  };

  flake-file.inputs.nix-flatpak = {
    url = "github:gmodena/nix-flatpak";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.flatpak.nixos = { ... }: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [
        "org.vinegarhq.Sober"
      ];
    };
  };
}
