{
  sn,
  lib,
  ...
}:
let
  commonNixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operator"
    ];
    log-lines = 25;
    auto-optimise-store = true;
    warn-dirty = false;
    keep-outputs = true;
    min-free = 2147483648; # 2GB
    max-free = 5368709120; # 5GB
    builders-use-substitutes = true;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nixToolsPkgs =
    pkgs: with pkgs; [
      nix-output-monitor
      dix
    ];
in
{
  sn.nix-base = {
    includes = [ sn.nix-settings ];
  };

  sn.nix-settings.nixos =
    {
      config,
      pkgs,
      ...
    }:
    {
      options.core.nix-settings.cores = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 0;
        description = "Cores available to the Nix daemon per build (0 = all cores).";
      };

      config = {
        nix.enable = lib.mkDefault true;
        nix.daemonCPUSchedPolicy = "batch";
        nix.daemonIOSchedPriority = 7;
        nix.settings = commonNixSettings // {
          cores = config.core.nix-settings.cores;
        };

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
    };

  sn.nix-settings.darwin = _: {
    nixpkgs.overlays = [
      (_final: prev: {
        # dix's test suite asserts store paths start with /nix/store or /tmp,
        # but macOS's sandbox resolves TMPDIR through /private/tmp, tripping
        # that assertion on every build. Doesn't affect the built binary.
        # nixpkgs already skips 4 known-bad tests for this and sets TMPDIR,
        # but that's incomplete here (11 more fail across other modules) —
        # TODO: revisit (added 2026-07-06) once nixpkgs' dix packaging covers
        # the rest, or report upstream to manic-systems/dix.
        dix = prev.dix.overrideAttrs (_old: {
          doCheck = false;
        });
        # test_read_text_file picks an arbitrary small file from /nix/store and
        # asserts its contents don't contain "Error" — flaky, since real store
        # content (e.g. minified JS) can legitimately contain that word.
        mcp-nixos = prev.mcp-nixos.overrideAttrs (old: {
          disabledTests = (old.disabledTests or [ ]) ++ [ "test_read_text_file" ];
        });
      })
    ];

    # mkDefault false — lix.nix overrides to true when Lix manages the daemon.
    nix.enable = lib.mkDefault false;
    nix.settings = commonNixSettings;
  };

  sn.nix-settings.os = { pkgs, ... }: {
    # Flake-only setup; nothing here uses angle-bracket <nixpkgs> lookups, and
    # root never runs nix-channel, so the default search path just warns about
    # a channels profile that doesn't exist.
    nix.nixPath = [ ];
    nixpkgs.config.allowUnfree = true;
    nix.extraOptions = ''
      !include /etc/nix/access-tokens.conf
    '';
    environment.systemPackages = nixToolsPkgs pkgs;
  };
}
