{
  pins = {
    nixpkgs = {
      url = "https://github.com/nixos/nixpkgs";
      ref = "nixos-unstable";
    };
    pnix.url = "https://github.com/bunny-systems/pnix";
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
