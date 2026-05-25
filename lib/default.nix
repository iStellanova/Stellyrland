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
    aspects ? [],
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

    # Dynamically resolve OS modules based on enabled aspects.
    # Fallback: if aspects is empty, we import all modules to support legacy toggle setups.
    osRegistry =
      if isDarwin
      then config.flake.modules.darwin
      else config.flake.modules.nixos;

    activeOSModules =
      (
        if aspects == []
        then lib.attrValues osRegistry
        else map (name: osRegistry.${name}) (lib.filter (name: osRegistry ? ${name}) aspects)
      )
      ++ lib.optional (osRegistry ? meta) osRegistry.meta;

    # Dynamically resolve Home Manager modules based on enabled aspects.
    hmRegistry = config.flake.modules.homeManager;
    activeHmModules =
      if aspects == []
      then lib.attrValues hmRegistry
      else map (name: hmRegistry.${name}) (lib.filter (name: hmRegistry ? ${name}) aspects);
  in
    coreBuilder {
      inherit system;
      modules =
        activeOSModules
        ++ [
          hmModule
          ({config, ...}: {
            # Inject enabledAspects list into module arguments for safe cross-aspect querying
            _module.args.enabledAspects = aspects;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
              sharedModules = activeHmModules ++ [{_module.args.enabledAspects = aspects;}];
              users.${config.identity.username} = {
                home.username = config.identity.username;
                home.homeDirectory = config.identity.homeDir;
              };
            };
          })
        ]
        ++ extraModules;
    };
}
