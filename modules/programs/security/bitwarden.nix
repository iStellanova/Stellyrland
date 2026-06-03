_: {
  # NixOS Bitwarden Settings
  flake.modules.nixos.bitwarden = _: {
    services.flatpak.packages = ["com.bitwarden.desktop"];
  };

  # Darwin Bitwarden Settings
  flake.modules.darwin.bitwarden = _: {
    homebrew.casks = ["bitwarden"];
  };
}
