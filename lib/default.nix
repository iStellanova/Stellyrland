{ lib, ... }: {
  # Recursively find all .nix files in a directory
  # This version is non-recursive to avoid complex path logic for now
  # and just does a simple scan of the directories we created.
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
