{ lib, ... }: {
  # scan - The core engine of the "Dendritic" configuration pattern.
  # This function recursively searches a directory for .nix files and default.nix folders,
  # allowing for zero-boilerplate module discovery and automatic inclusion in the system flake.
  scan = path:
    let
      items = builtins.readDir path;
      res = lib.flatten (lib.mapAttrsToList (name: type:
        let
          fullPath = path + "/${name}";
          isDefault = builtins.pathExists (fullPath + "/default.nix");
        in
        if type == "directory" then
          if isDefault then [ (fullPath + "/default.nix") ]
          else (import ./default.nix { inherit lib; }).scan fullPath
        else if lib.hasSuffix ".nix" name then
          [ fullPath ]
        else
          []
      ) items);
    in
    res;
}
