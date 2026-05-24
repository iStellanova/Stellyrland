{lib, ...}: {
  # scan - The core engine of the "Dendritic" configuration pattern.
  # This function recursively searches a directory for .nix files and default.nix folders,
  # allowing for zero-boilerplate module discovery and automatic inclusion in the system flake.
  scan = path: let
    items = builtins.readDir path;
    res = lib.flatten (lib.mapAttrsToList (
        name: type: let
          fullPath = path + "/${name}";
        in
          if lib.hasPrefix "_" name || lib.hasPrefix "." name
          then []
          else if type == "directory"
          then (import ./default.nix {inherit lib;}).scan fullPath
          else if lib.hasSuffix ".nix" name
          then [fullPath]
          else []
      )
      items);
  in
    res;

  # mkHost - Builds a NixOS or Darwin system configuration from the dendritic module store.
  # Accepts the flake-parts top-level `config` and `inputs` so it can read
  # flake.modules.{nixos,darwin,homeManager} without circular references.
  mkHost = {
    config,
    inputs,
  }: {
    system,
    isDarwin,
    extraModules ? [],
  }: let
    coreBuilder =
      if isDarwin
      then inputs.nix-darwin.lib.darwinSystem
      else inputs.nixpkgs.lib.nixosSystem;
    hmModule =
      if isDarwin
      then inputs.home-manager.darwinModules.home-manager
      else inputs.home-manager.nixosModules.home-manager;
    sharedHmModules =
      (lib.attrValues config.flake.modules.homeManager)
      ++ [
        inputs.catppuccin.homeModules.catppuccin
        inputs.nix-index-database.homeModules.nix-index
        inputs.nixvim.homeModules.nixvim
      ];
  in
    coreBuilder {
      inherit system;
      modules =
        (
          if isDarwin
          then lib.attrValues config.flake.modules.darwin
          else lib.attrValues config.flake.modules.nixos
        )
        ++ [
          hmModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
              sharedModules = sharedHmModules;
            };
          }
        ]
        ++ extraModules;
    };
}
