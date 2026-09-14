{ inputs, lib, self, ... }:
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
        nixfmt.enable = true;
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

  formatter = lib.genAttrs systems (system: treefmtEval.${system}.config.build.wrapper);
  checks = lib.genAttrs systems (system: {
    formatting = treefmtEval.${system}.config.build.check self;
  });
}
