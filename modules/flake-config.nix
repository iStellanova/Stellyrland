{ lib, ... }:
{
  options = {
    flake.modules = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
      internal = true;
    };
    pins = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      internal = true;
    };
  };

  config.systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
}
