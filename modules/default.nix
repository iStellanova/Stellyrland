{ lib, isDarwin ? false, ... }: {
  imports = (lib.scan ./common)
            ++ (if isDarwin then (lib.scan ./darwin) else (lib.scan ./nixos));
}
