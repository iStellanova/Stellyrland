{
  modules.nixos.backup-sender =
    { lib, config, host, ... }:
    let
      cfg = config.backup.sender;
      jobName = config.networking.hostName;
    in
    {
      options.backup.sender = {
        enable = lib.mkEnableOption "weekly Borg backups";

        paths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        repo = lib.mkOption {
          type = lib.types.str;
        };

        mountpoint = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.paths != [ ];
            message = "backup.sender.paths must not be empty";
          }
        ];

        security.nix-secrets.secrets.backup-pass = {
          path = "/run/secrets/backup-pass";
          owner = "root";
          group = "root";
          mode = "0400";
          recipients = [
            "stellanova"
            host.name
          ];
        };

        services.borgbackup.jobs.${jobName} = {
          inherit (cfg) paths repo;
          startAt = "weekly";
          persistentTimer = true;
          compression = "auto,zstd,3";
          encryption = {
            mode = "repokey-blake2";
            passCommand = "cat /run/secrets/backup-pass";
          };
          prune.keep = {
            weekly = 8;
            monthly = 12;
            yearly = 3;
          };
        };

        systemd.services."borgbackup-job-${jobName}".unitConfig = lib.mkIf (cfg.mountpoint != null) {
          ConditionPathIsMountPoint = cfg.mountpoint;
        };
      };
    };
}
