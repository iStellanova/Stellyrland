{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.aspects.core.nix-settings.enable {
    # Nix settings for Linux.
    nix.daemonCPUSchedPolicy = "idle"; # Idle CPU scheduling policy for the Nix daemon.
    nix.daemonIOSchedPriority = 7; # IO scheduling priority for the Nix daemon.

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

    # Environment variables.
    environment.variables = {
      NIXOS_OZONE_WL = "1"; # Enable Ozone Wayland support.
    };
  };
}
