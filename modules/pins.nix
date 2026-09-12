{
  pins = {
    nixpkgs = {
      url = "https://github.com/nixos/nixpkgs";
      ref = "nixos-unstable";
    };
    flake-parts = {
      url = "https://github.com/hercules-ci/flake-parts";
      follows.nixpkgs-lib = "nixpkgs";
    };
    import-tree.url = "https://github.com/vic/import-tree";
    home-manager = {
      url = "https://github.com/nix-community/home-manager";
      ref = "master";
      follows.nixpkgs = "nixpkgs";
    };
    darwin = {
      url = "https://github.com/LnL7/nix-darwin";
      follows.nixpkgs = "nixpkgs";
    };
    my-assets = {
      url = "https://github.com/iStellanova/Stellyrland";
      ref = "assets";
      flake = false;
    };
  };
}
