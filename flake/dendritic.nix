{
  inputs,
  lib,
  ...
}: let
  # Scan all files under modules recursively
  inherit ((import ../lib/default.nix {inherit lib;})) scan;
  allFiles = scan ../modules;
in {
  # Dynamically import all discovered modules at the top level
  imports = allFiles;

  # Export extended library as a flake output
  flake.lib = inputs.nixpkgs.lib.extend (self: _super: (import ../lib/default.nix {lib = self;}));
}
