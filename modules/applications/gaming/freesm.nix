{ inputs, ... }:
{
  flake-file.inputs.freesmlauncher = {
    url = "github:FreesmTeam/FreesmLauncher";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.finix.freesm =
    { inputs, pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.modules.nixos.freesm =
    { pkgs, ... }:
    {
      # Freesm's own binary cache — avoids building the Qt/CMake source locally.
      nix.settings.substituters = [ "https://freesmlauncher.cachix.org" ];
      nix.settings.trusted-public-keys = [
        "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
      ];

      environment.systemPackages = [
        inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
