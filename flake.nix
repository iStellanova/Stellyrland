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
      result = inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
    in
    result;
}
