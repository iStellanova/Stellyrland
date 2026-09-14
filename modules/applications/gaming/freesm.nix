{ inputs, ... }:
{
  pins.freesmlauncher = {
    url = "https://github.com/FreesmTeam/FreesmLauncher";
    follows.nixpkgs = "nixpkgs";
  };

  modules.nixos.freesm =
    { pkgs, ... }:
    {
      nix.settings.substituters = [ "https://freesmlauncher.cachix.org" ];
      nix.settings.trusted-public-keys = [
        "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
      ];

      environment.systemPackages = [
        inputs.freesmlauncher.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
