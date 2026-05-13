{ lib, ... }: {
  options.aspects.core.monitors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {
      DP-2 = "3440x1440@175, 1440x541, 1, sdrbrightness, 1.2, sdrsaturation, 0.98";
      DP-3 = "2560x1440@100, 0x0, 1, transform, 1, sdrbrightness, 1.2, sdrsaturation, 0.98";
    };
    description = "Centralized monitor configuration strings for graphical environments.";
  };
}
