{inputs ? {}, ...}: {
  den.aspects.bitwarden.nixos = _: {
    imports =
      if inputs ? nix-flatpak
      then [inputs.nix-flatpak.nixosModules.nix-flatpak]
      else [];

    services.flatpak.packages = ["com.bitwarden.desktop"];
  };

  den.aspects.bitwarden.darwin = _: {
    homebrew.casks = ["bitwarden"];
  };
}
