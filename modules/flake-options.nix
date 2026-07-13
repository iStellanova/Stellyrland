{ lib, ... }:
{
  # flake-parts declares flake.nixosConfigurations itself, but not darwinConfigurations —
  # this is a known gap, patched the same way the Doc-Steve dendritic reference does it
  # (their version used the now-deprecated flake-parts-lib.mkSubmoduleOptions workaround;
  # direct dot-notation declaration is the modern, non-deprecated equivalent).
  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };

  # flake.hosts is our own convention (no flake-parts or reference-repo equivalent) —
  # needs the same declaration treatment so multiple host files can each contribute
  # their own key without "defined multiple times" errors.
  options.flake.hosts = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };

  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };

  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };
}
