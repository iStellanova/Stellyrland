{
  description = "Stellyrland System Configurations.";
  outputs =
    { self }:
    let
      inputs = (import ./.pnix { }) // {
        inherit self;
      };
      lib = inputs.nixpkgs.lib;
      importTree =
        path:
        let
          files = map toString (lib.filesystem.listFilesRecursive path);
        in
        lib.foldl' lib.recursiveUpdate { } (
          map (file: removeAttrs (lib.toFunction (import file) { inherit inputs self lib; }) [ "pins" ]) (
            builtins.filter (p: lib.hasSuffix ".nix" p && !lib.hasInfix "/_" p) files
          )
        );
    in
    importTree ./modules;
}
