{ inputs, ... }: {
  flake-file.inputs.treefmt-nix = {
    url = "github:numtide/treefmt-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      # git-crypt encrypted; appears as ciphertext when the key isn't unlocked locally
      settings.global.excludes = [
        ".tack/*"
        "modules/hosts/famtop/_identity.nix"
      ];
      programs = {
        nixfmt.enable = true;
        deadnix.enable = true;
        statix.enable = true;
      };
    };
  };
}
