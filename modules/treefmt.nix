{
  inputs,
  lib,
  self,
  ...
}:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  treefmtEval = lib.genAttrs systems (
    system:
    inputs.treefmt-nix.lib.evalModule inputs.nixpkgs.legacyPackages.${system} {
      projectRootFile = "flake.nix";
      programs = {
        deadnix.enable = true;
        statix.enable = true;
      };
    }
  );
in
{
  pins.treefmt-nix = {
    url = "https://github.com/numtide/treefmt-nix";
    follows.nixpkgs = "nixpkgs";
  };

  checks = lib.genAttrs systems (system: {
    linting = treefmtEval.${system}.config.build.check self;
  });
}
