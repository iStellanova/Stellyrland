{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.flake-file.flakeModules.tack
    inputs.flake-parts.flakeModules.modules
  ];

  flake-file.tack.recomposable = null;

  # TODO: revisit — deliberately not flake-file's default (pkgs.tack, i.e.
  # nixpkgs' tack). nixpkgs still tracks the tack v1.0.0 tag, whose
  # checkPhase opens a real TCP listener in fetch::git_http::tests and dies
  # with EADDRNOTAVAIL under the macOS sandbox — confirmed still broken
  # 2026-07-17. Our own nixpkgs-followed input tracks a later, unreleased
  # commit where that test was fixed. Drop this override once nixpkgs' tack
  # moves past v1.0.0 to include the fix.
  flake-file.tack.package = pkgs: inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.tack;

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
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

  perSystem = { pkgs, ... }: {
    packages = lib.mapAttrs (_: f: f pkgs) config.flake-file.apps;
  };

  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
