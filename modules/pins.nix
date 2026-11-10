{
  pins = {
    nixpkgs = {
      url = "https://github.com/nixos/nixpkgs";
      ref = "nixos-unstable";
      # TODO: Remove when nixos-unstable includes the primp system-libraries fix.
      importable = true;
      patches = [
        { commit = "b9eb668f72ae56cfbb69190682086d82ca73f61b"; }
      ];
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
