{lib, ...}: let
  mkIdentityOpts = homeDirDefault: {
    username = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "stellanova";
      description = "The primary user username.";
    };
    homeDir = lib.mkOption {
      type = lib.types.str;
      default = homeDirDefault;
      description = "The primary user home directory.";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The primary user email address.";
    };
    gitName = lib.mkOption {
      type = lib.types.singleLineStr;
      default = "stellanova";
      description = "The name used in git commits.";
    };
    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Authorized SSH public keys.";
    };
    hashedPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Hashed password for the user (when secrets aren't active).";
    };
    dataPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to custom static assets (wallpapers, icons).";
    };
  };
in {
  options = {
    hosts.nixos = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.str;
            default = "x86_64-linux";
            description = "The target CPU/OS architecture.";
          };
          aspects = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "List of active dendritic aspects for this host.";
          };
          modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "List of NixOS configurations/modules for this host.";
          };
        };
      });
      default = {};
      description = "Declarative NixOS host specifications.";
    };

    hosts.darwin = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.str;
            default = "aarch64-darwin";
            description = "The target Darwin CPU/OS architecture.";
          };
          aspects = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "List of active dendritic aspects for this host.";
          };
          modules = lib.mkOption {
            type = lib.types.listOf lib.types.deferredModule;
            default = [];
            description = "List of Darwin configurations/modules for this host.";
          };
        };
      });
      default = {};
      description = "Declarative Darwin host specifications.";
    };
  };

  config = {
    flake.modules.nixos.meta = _: {options.identity = mkIdentityOpts "/home/stellanova";};
    flake.modules.darwin.meta = _: {options.identity = mkIdentityOpts "/Users/stellanova";};
  };
}
