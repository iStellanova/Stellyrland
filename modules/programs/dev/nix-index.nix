{inputs, ...}: {
  # Home Manager nix-index Settings
  flake.modules.homeManager.nix-index = {...}: {
    imports = [inputs.nix-index-database.homeModules.nix-index];

    config = {
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;
    };
  };
}
