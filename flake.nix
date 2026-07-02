{
  outputs =
    { self, ... }:
    let
      rawInputs = import ./.tack;
      inputs = rawInputs // {
        self = self';
      };
      self' = outputs // {
        inherit inputs;
        inherit (self) outPath;
      };
      outputs = rawInputs.flake-parts.lib.mkFlake { inherit inputs; } (rawInputs.import-tree ./modules);
    in
    outputs;
}
