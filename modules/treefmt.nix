{inputs, ...}: {
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports =
    if inputs ? treefmt-nix
    then [inputs.treefmt-nix.flakeModule]
    else [];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      settings.global.excludes = [".tack/*"];
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
    };
  };
}
