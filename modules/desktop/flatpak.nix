{ inputs, ... }:
{
  flake-file.inputs.nix-flatpak = {
    url = "github:gmodena/nix-flatpak";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.flatpak = { ... }: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [
        "org.vinegarhq.Sober"
      ];
    };
    systemd.services.flatpak-managed-install = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
