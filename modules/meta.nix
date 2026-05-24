_: {
  config = {
    # NixOS level identity options
    flake.modules.nixos.meta = {lib, ...}: {
      options.identity = {
        username = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "stellanova";
          description = "The primary user username.";
        };
        homeDir = lib.mkOption {
          type = lib.types.str;
          default = "/home/stellanova";
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
    };

    # Darwin level identity options
    flake.modules.darwin.meta = {lib, ...}: {
      options.identity = {
        username = lib.mkOption {
          type = lib.types.singleLineStr;
          default = "stellanova";
          description = "The primary user username.";
        };
        homeDir = lib.mkOption {
          type = lib.types.str;
          default = "/Users/stellanova";
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
          description = "Hashed password for the user.";
        };
        dataPath = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to custom static assets (wallpapers, icons).";
        };
      };
    };
  };
}
