{
  description = "Stellyrland System Configurations.";
  outputs =
    { self }:
    let
      inputs = (import ./.pnix { }) // {
        inherit self;
      };
      lib = inputs.nixpkgs.lib;
      mergeModules =
        old: new:
        lib.zipAttrsWith
          (
            _: classes:
            lib.zipAttrsWith (
              _: leaves: if builtins.length leaves == 1 then builtins.head leaves else { imports = leaves; }
            ) classes
          )
          [
            old
            new
          ];
      importTree =
        path:
        path
        |> lib.fileset.fileFilter (file: file.hasExt "nix" && !lib.hasPrefix "_" file.name)
        |> lib.fileset.toList
        |> map (file: lib.toFunction (import file) { inherit inputs self lib; })
        |> lib.foldl' (
          old: new:
          (lib.recursiveUpdate old new)
          // {
            modules = mergeModules (old.modules or { }) (new.modules or { });
          }
        ) { };
    in
    builtins.removeAttrs (importTree ./modules) [ "pins" ];
}
