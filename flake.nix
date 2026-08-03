{
  outputs =
    { self, ... }:
    let
      rawInputs = import ./.tack;
      inputs = rawInputs // {
        self = self';
      };
      self' = result // {
        inherit inputs;
        inherit (self) outPath;
      };
      # Recursively imports modules with a tree function.
      importTree =
        dir:
        let
          inherit (rawInputs.nixpkgs) lib;
          files = map toString (lib.filesystem.listFilesRecursive dir);
        in
        {
          imports = builtins.filter (p: lib.hasSuffix ".nix" p && !(lib.hasInfix "/_" p)) files;
        };

      result = inputs.flake-parts.lib.mkFlake { inherit inputs; } (importTree ./modules);
    in
    result;
}
