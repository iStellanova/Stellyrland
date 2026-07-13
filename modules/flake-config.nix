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

  # TODO: revisit — tack's checkPhase spins up real TCP listeners for its
  # HTTP-fetch tests. Nix's macOS build sandbox denies network socket
  # operations for regular (non-fixed-output) derivations, and that denial
  # surfaces as EADDRNOTAVAIL rather than a permission error, so it looks
  # like an address problem but isn't one — confirmed by binding
  # 127.0.0.1:0 directly on this machine outside the sandbox, which works
  # fine. (Upstream issue manic-systems/tack#81 / PR #82, which swapped a
  # 127.0.0.2 literal for 127.0.0.1, fixes the same symptom only on
  # unsandboxed CI runners — it doesn't help here.) Only escape hatches are
  # `--option sandbox false` (requires being a trusted user in nix.conf) or
  # tack dropping real sockets from its test suite. Reuses our
  # already-resolved (nixpkgs-followed) tack input rather than flake-file's
  # own separately-pinned default.
  flake-file.tack.package =
    pkgs:
    inputs.tack.packages.${pkgs.system}.tack.overrideAttrs (_: {
      doCheck = false;
    });

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
