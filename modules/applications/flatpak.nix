{ inputs, ... }:
{
  flake-file.inputs.nix-flatpak = {
    url = "github:gmodena/nix-flatpak";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.flatpak = _: {
    imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

    services.flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [
        "io.github.kolunmi.Bazaar"
      ];
    };
    # nix-flatpak's own unit only orders after multi-user.target, so a flatpak
    # install can run before the network is up and fail.
    systemd.services.flatpak-managed-install = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
