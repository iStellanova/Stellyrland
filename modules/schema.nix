{
  lib,
  inputs,
  ...
}:
{
  # Users default to the homeManager class — triggers Den's host-to-hm-users policy,
  # which auto-imports home-manager.nixosModules/darwinModules.home-manager per host.
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Universal HM defaults that apply to every user entity across all hosts.
  den.default.homeManager.home.stateVersion = "25.11";

  # HM wiring options — defined once here via `os` class (routes to nixos + darwin).
  den.default.os.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    overwriteBackup = true;
  };

  # Typed fields for all host entities. Accessible as `host.*` in aspects via { host } context.
  den.schema.host =
    { host, ... }:
    {
      options = {
        # Derived from the `users.<name> = {}` key already declared per-host (den-native data),
        # rather than independently restated — one host with no users declared is a real error,
        # not a case to paper over with a fallback.
        username = lib.mkOption {
          type = lib.types.singleLineStr;
          default = lib.head (lib.attrNames host.users);
          description = "Primary user's system username.";
        };
        # Computed from username + class instead of restated per host — /home vs /Users is
        # purely a platform fact, not something each host should have to spell out.
        homeDir = lib.mkOption {
          type = lib.types.str;
          default = if host.class == "darwin" then "/Users/${host.username}" else "/home/${host.username}";
          description = "Absolute path to the primary user's home directory.";
        };
        flakePath = lib.mkOption {
          type = lib.types.str;
          default = "/etc/nixos";
          description = "Absolute path to the Nix flake on this host.";
        };
        gitName = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "stellanova";
          description = "Display name used in git commits.";
        };
        userEmail = lib.mkOption {
          type = lib.types.str;
          default = "iStellanova@users.noreply.github.com";
          description = "Primary user's email address.";
        };
        sshKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
          ];
          description = "Authorized SSH public keys.";
        };
        dataPath = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = inputs.my-assets;
          description = "Path to custom static assets (wallpapers, icons).";
        };
        # Ambient: read independently by hyprland, noctalia, and headless boot config, which have
        # no behavioral relationship to each other — without this, each would independently type
        # the same physical output names with no way to keep them in sync.
        monitorPriority = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Physical monitor outputs in priority order (primary first).";
        };
        features = lib.mkOption {
          type = lib.types.submodule {
            options = {
              # Ambient: read independently by gaming/gamescope.nix and av/gsr.nix,
              # which have no behavioral relationship to each other — see
              # modules/hosts/stellyrland/aspect.nix for how gamescope's own toggle
              # derives from this. secureBoot has one true owner (linux-boot/boot.nix)
              # and was removed from here for that reason. coolerControl/lact were
              # also removed — both are unconditionally bundled into sn.system now,
              # so inclusion itself is their toggle, no schema flag needed.
              hdr = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Enable HDR display support.";
              };
            };
          };
          default = { };
          description = "Feature flags for hardware-specific aspects.";
        };
      };
    };
}
