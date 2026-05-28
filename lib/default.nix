{lib, ...}: {
  # Lib scanner for the directory tree. Grabs all the nix files, ignores "_" files that go unused or have alternative imports. Excluded from auto-imports.
  scan = let
    scan' = path:
      lib.concatMap (
        {
          name,
          value,
        }: let
          fullPath = path + "/${name}";
        in
          if lib.hasPrefix "_" name || lib.hasPrefix "." name
          then []
          else if value == "directory"
          then scan' fullPath
          else if lib.hasSuffix ".nix" name
          then [fullPath]
          else []
      )
      (lib.attrsToList (builtins.readDir path));
  in
    scan';

  # mkHost - Creates a host based on imported aspects with their respective architectures.
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
    osRegistry =
      if isDarwin
      then config.flake.modules.darwin
      else config.flake.modules.nixos;

    activeOSModules =
      if aspects == []
      then lib.attrValues osRegistry
      else
        map (name: osRegistry.${name}) (lib.filter (name: osRegistry ? ${name}) aspects)
        # meta is always injected; append only if not already resolved via aspects.
        ++ lib.optional (osRegistry ? meta && !(builtins.elem "meta" aspects)) osRegistry.meta;

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
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
              sharedModules = activeHmModules;
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
