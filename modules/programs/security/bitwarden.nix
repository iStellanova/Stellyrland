_: {
  # NixOS Bitwarden Settings
  flake.modules.nixos.bitwarden = {pkgs, ...}: {
    environment.systemPackages = [pkgs.bitwarden-desktop];
  };

  # Darwin Bitwarden Settings
  flake.modules.darwin.bitwarden = _: {
    homebrew.casks = ["bitwarden"];
  };
}
