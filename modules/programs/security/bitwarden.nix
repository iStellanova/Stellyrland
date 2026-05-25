_: {
  # NixOS Bitwarden Settings
  flake.modules.nixos.bitwarden = {pkgs, ...}: {
    config = {
      environment.systemPackages = [pkgs.bitwarden-desktop];
    };
  };

  # Darwin Bitwarden Settings
  flake.modules.darwin.bitwarden = _: {
    config = {
      homebrew.casks = ["bitwarden"];
    };
  };
}
