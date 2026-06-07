{lib, ...}: {
  # Users default to the homeManager class — triggers Den's host-to-hm-users policy,
  # which auto-imports home-manager.nixosModules/darwinModules.home-manager per host.
  den.schema.user.classes = lib.mkDefault ["homeManager"];

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
  den.schema.host.options = {
    username = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "stellanova";
      description = "Primary user's system username.";
    };
    homeDir = lib.mkOption {
      type = lib.types.str;
      default = "";
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
      default = "";
      description = "Primary user's email address.";
    };
    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Authorized SSH public keys.";
    };
    dataPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to custom static assets (wallpapers, icons).";
    };
    features = lib.mkOption {
      type = lib.types.submodule {
        options = {
          secureBoot = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Secure Boot via lanzaboote.";
          };
          hdr = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable HDR display support.";
          };
          coolerControl = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable CoolerControl fan/thermal management.";
          };
          lact = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable LACT AMD GPU control daemon.";
          };
        };
      };
      default = {};
      description = "Feature flags for hardware-specific aspects.";
    };
  };
}
