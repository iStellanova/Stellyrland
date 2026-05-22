{
  inputs,
  lib,
  ...
}: let
  # Scan all files under modules recursively
  inherit ((import ../lib/default.nix {inherit lib;})) scan;
  allFiles = scan ../modules;

  # Check if a path represents a pure dendritic module (contains flake.modules)
  isPure = path: lib.strings.hasInfix "flake.modules" (builtins.readFile path);

  # Separate all scanned files
  pureDendritic = lib.filter isPure allFiles;
in {
  # Dynamically import all pure dendritic modules at the top level
  imports = pureDendritic;

  # Export extended library as a flake output
  flake.lib = inputs.nixpkgs.lib.extend (self: _super: (import ../lib/default.nix {lib = self;}));
}
