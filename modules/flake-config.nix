{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.den.flakeModules.default
    inputs.flake-file.flakeModules.default
  ];

  flake-file.description = "Stellyrland Configurations";
  flake-file.outputs = "dendritic";

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    den.url = "github:denful/den";
    import-tree.url = "github:vic/import-tree";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
