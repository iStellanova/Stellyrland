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
    imports =
      if inputs ? nix-index-database
      then [inputs.nix-index-database.homeModules.nix-index]
      else [];

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };
}
