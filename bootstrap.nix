{
  inputs,
  lib,
  ...
}: let
  # Bootstrap: import lib once with the plain lib argument for scanning.
  # A second extension is used for the exported flake.lib so callers get the
  # fully-extended version, but we avoid importing default.nix twice here.
  myLib = import ./lib/default.nix {inherit lib;};
in {
  # Dynamically import all discovered modules at the top level.
  imports = myLib.scan ./modules;

  # Export the extended library as a flake output.
  flake.lib = inputs.nixpkgs.lib.extend (
    self: _super: import ./lib/default.nix {lib = self;}
  );
}
