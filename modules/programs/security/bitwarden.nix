{inputs, ...}: {
  den.aspects.bitwarden.nixos = _: {
    imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];

    services.flatpak.packages = ["com.bitwarden.desktop"];
  };

  den.aspects.bitwarden.darwin = _: {
    homebrew.casks = ["bitwarden"];
  };
}
