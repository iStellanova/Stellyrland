{
  description = "Stellyrland System Configurations.";

  outputs = { self }:
    let
      inputs = (import ./.pnix { }) // { inherit self; };
      importTree =
        dir:
        let
          inherit (inputs.nixpkgs) lib;
          files = map toString (lib.filesystem.listFilesRecursive dir);
        in
        {
          imports = builtins.filter (p: lib.hasSuffix ".nix" p && !(lib.hasInfix "/_" p)) files;
        };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (importTree ./modules);
}
