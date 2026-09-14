{
  description = "Stellyrland System Configurations.";

  outputs = { self }:
    let
      inputs = (import ./.pnix { }) // { inherit self; };
      lib = inputs.nixpkgs.lib;
      mergeModules = old: new:
        lib.foldl' (
          result: class:
          result
          // {
            ${class} = lib.foldl' (
              classResult: name:
              classResult
              // {
                ${name} =
                  if builtins.hasAttr name classResult then
                    { imports = [ classResult.${name} new.${class}.${name} ]; }
                  else
                    new.${class}.${name};
              }
            ) (old.${class} or { }) (builtins.attrNames new.${class});
          }
        ) old (builtins.attrNames new);
      importTree =
        path:
        path
        |> lib.fileset.fileFilter (file: file.hasExt "nix" && !lib.hasPrefix "_" file.name)
        |> lib.fileset.toList
        |> map (file: lib.toFunction (import file) { inherit inputs self lib; })
        |> lib.foldl' (
          old: new:
          let
            merged = lib.recursiveUpdate old new;
          in
          merged
          // {
            flake = (merged.flake or { }) // {
              modules = mergeModules (old.flake.modules or { }) (new.flake.modules or { });
            };
          }
        ) { };
    in
    (importTree ./modules).flake;
}
