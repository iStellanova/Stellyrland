{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.flake-file.flakeModules.flake
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
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

  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
}
