{inputs, ...}: {
  den.aspects.nix-index.homeManager = {...}: {
    imports = [inputs.nix-index-database.homeModules.nix-index];

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
  };
}
