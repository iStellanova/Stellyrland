{
  config,
  lib,
  pkgs,
  ...
}: {
  options.aspects.core.nix-settings.cores = lib.mkOption {
    type = lib.types.ints.unsigned;
    default = 0;
    description = "Cores available to the Nix daemon per build (0 = all cores).";
  };

  config = lib.mkIf config.aspects.core.nix-settings.enable {
    nix.daemonCPUSchedPolicy = "batch";
    nix.daemonIOSchedPriority = 7;
    nix.settings.cores = config.aspects.core.nix-settings.cores;

    # Support for dynamically linked executables.
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
    ];

    nix.settings.substituters = [
      "https://cache.nixos.org"
    ];
    nix.settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    # Environment variables.
    environment.variables = {
      NIXOS_OZONE_WL = "1"; # Enable Ozone Wayland support.
    };
  };
}
