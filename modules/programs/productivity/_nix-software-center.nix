{inputs ? {}, ...}: {
  flake-file.inputs.nix-software-center = {
    url = "github:snowfallorg/nix-software-center";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.nix-software-center.homeManager = {pkgs, ...}: {
    home.packages = [
      inputs.nix-software-center.packages."${pkgs.stdenv.hostPlatform.system}".default
    ];
  };
}
