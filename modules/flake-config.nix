{
  inputs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.den.flakeModules.default
    inputs.flake-file.flakeModules.tack
  ];

  flake-file.tack.recomposable = null;

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    den = {
      url = "github:denful/den";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    tack = {
      url = "github:manic-systems/tack";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-assets = {
      url = "github:iStellanova/Stellyrland/assets";
      flake = false;
    };
  };

  perSystem = {pkgs, ...}: {
    packages = lib.mapAttrs (_: f: f pkgs) config.flake-file.apps;
  };

  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
