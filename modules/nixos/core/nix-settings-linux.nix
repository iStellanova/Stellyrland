{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.aspects.core.nix-settings.enable {
    nix.daemonCPUSchedPolicy = "idle";
    nix.daemonIOSchedPriority = 7;

    # Support for dynamically linked executables
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

    environment.variables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
