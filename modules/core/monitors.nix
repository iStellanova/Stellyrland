_: {
  config = {
    flake.modules.nixos.monitors = {lib, ...}: {
      options.aspects.core.monitors = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          DP-2 = "3440x1440@175, 1440x541, 1, bitdepth, 10, cm, hdr";
          DP-3 = "2560x1440@100, 0x0, 1, transform, 1, bitdepth, 10, cm, hdr";
        };
        description = "Centralized monitor configuration strings for graphical environments.";
      };
    };

    flake.modules.darwin.monitors = {lib, ...}: {
      options.aspects.core.monitors = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          DP-2 = "3440x1440@175, 1440x541, 1, bitdepth, 10, cm, hdr";
          DP-3 = "2560x1440@100, 0x0, 1, transform, 1, bitdepth, 10, cm, hdr";
        };
        description = "Centralized monitor configuration strings for graphical environments.";
      };
    };
  };
}
