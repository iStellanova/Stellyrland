_: {
  den.aspects.bitwarden.nixos = _: {
    services.flatpak.packages = ["com.bitwarden.desktop"];
  };

  den.aspects.bitwarden.darwin = _: {
    homebrew.casks = ["bitwarden"];
  };
}
