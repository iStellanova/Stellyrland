{ inputs, ... }:
{
  flake-file.inputs.nix-flatpak = {
    url = "github:gmodena/nix-flatpak";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.gnome = {
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
      ./_extensions.nix
      ./_dconf.nix
    ];

    services.desktopManager.gnome.enable = true;
    services.displayManager.gdm.enable = true;

    services.printing.enable = true;

    # Enabled, no declared packages — family installs apps themselves via
    # GNOME Software/flatpak CLI, never touching the flake.
    services.flatpak.enable = true;
  };
}
