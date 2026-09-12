{ inputs, ... }: {
  pins.treefmt-nix = {
    url = "https://github.com/numtide/treefmt-nix";
    follows.nixpkgs = "nixpkgs";
  };

  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs = {
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
    };
  };
}
