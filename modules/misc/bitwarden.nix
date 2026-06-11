{inputs ? {}, ...}: {
  sn.bitwarden.nixos = _: {
    imports =
      if inputs ? nix-flatpak
      then [inputs.nix-flatpak.nixosModules.nix-flatpak]
      else [];

    services.flatpak.packages = ["com.bitwarden.desktop"];
  };

  sn.bitwarden.darwin = _: {
    homebrew.casks = ["bitwarden"];
  };
}
