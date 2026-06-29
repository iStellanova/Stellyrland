{
  sn,
  inputs,
  ...
}: {
  sn.dev = {includes = [sn.nix-index];};

  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.nix-index.homeManager = {...}: {
    imports = [inputs.nix-index-database.homeModules.nix-index];

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };
}
