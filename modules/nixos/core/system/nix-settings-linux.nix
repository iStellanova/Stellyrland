{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.aspects.core.nix-settings.enable {
    # Nix settings for Linux.
    nix.daemonCPUSchedPolicy = "batch"; # Batch scheduling for faster builds without UI lag.
    nix.daemonIOSchedPriority = 7; # IO scheduling priority for the Nix daemon.
    nix.settings.cores = 24; # Reserve 8 threads for system responsiveness.

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
