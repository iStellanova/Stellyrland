{
  flake.modules.nixos.backup-service =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (host) backup;
      isSource = backup ? datasets;
      isReceiver = backup ? enrolled;
      zfs = "${pkgs.zfs}/bin/zfs";
      zpool = "${pkgs.zfs}/bin/zpool";
      cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
      timeout = "${pkgs.coreutils}/bin/timeout";
      ssh = "${pkgs.openssh}/bin/ssh";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      flock = "${pkgs.util-linux}/bin/flock";
      sshKey = config.security.nix-secrets.secrets.stellacode.path;
      hddPartlabel = "disk-hdd-luks";
      mapperName = "crypthdd";
      poolName = "zhdd";

      receive =
        sourceName:
        pkgs.writeShellScript "backup-receive-${sourceName}" ''
          set -euo pipefail
          exec 9>/run/lock/backup-hdd.lock
          ${flock} -n 9 || exit 75
          opened=false; imported=false
          cleanup() {
            set +e
            $imported && ${zpool} export ${poolName}
            $opened && ${cryptsetup} close ${mapperName}
          }
          trap cleanup EXIT
          ! ${cryptsetup} status ${mapperName} >/dev/null 2>&1
          ! ${zpool} list ${poolName} >/dev/null 2>&1
          ${timeout} --foreground 2m ${cryptsetup} open --key-file ${config.security.nix-secrets.secrets.hdd-keyfile.path} /dev/disk/by-partlabel/${hddPartlabel} ${mapperName}
          opened=true
          ${zpool} import -d /dev/mapper/${mapperName} ${poolName}
          imported=true
          ${zfs} create -p ${poolName}/${sourceName}
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              dirName: _dir: "${systemctl} start --wait syncoid-${sourceName}-${dirName}.service"
            ) backup.enrolled.${sourceName}.datasets
          )}
          ${zpool} export ${poolName}; imported=false
          ${cryptsetup} close ${mapperName}; opened=false
        '';

      request =
        if isReceiver then
          "${receive host.name}"
        else
          ''
            ${ssh} -i ${sshKey} -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts backup-${host.name}@${backup.receiver.address} backup-request
          '';

      sourceModule = lib.optionalAttrs isSource (
        lib.recursiveUpdate
          {
            systemd.services."backup-${host.name}" = {
              after = [
                "network-online.target"
                "zfs.target"
              ];
              wants = [ "network-online.target" ];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = request;
              };
            };
            systemd.timers."backup-${host.name}" = {
              wantedBy = [ "timers.target" ];
              timerConfig = {
                OnCalendar = "Sun *-*-* 12:00:00";
                Persistent = true;
              };
            };
          }
          (
            lib.optionalAttrs (backup ? receiver) {
              programs.ssh.knownHosts.stellyrlab = {
                hostNames = [ backup.receiver.address ];
                publicKey = backup.receiver.publicKey;
              };
              systemd.services."backup-${host.name}-zfs-delegation" = {
                wantedBy = [ "zfs.target" ];
                after = [ "zfs.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                  ExecStart = lib.mapAttrsToList (
                    _name: dataset: "${zfs} allow -u ${host.username} snapshot,send,destroy,hold,release ${dataset}"
                  ) backup.datasets;
                };
              };
            }
          )
      );

      receiverModule = lib.optionalAttrs isReceiver {
        security.nix-secrets.secrets.hdd-keyfile = {
          recipients = [
            "stellanova"
            host.name
          ];
          owner = "root";
          group = "root";
          mode = "0400";
          path = "/run/secrets/hdd-keyfile";
        };
        services.udev.extraRules = ''
          SUBSYSTEM=="block", ENV{ID_PART_ENTRY_NAME}=="${hddPartlabel}", ENV{UDISKS_IGNORE}="1"
          SUBSYSTEM=="block", ENV{DM_NAME}=="${mapperName}", ENV{UDISKS_IGNORE}="1"
        '';
        programs.ssh.knownHosts = lib.mapAttrs' (
          name: source:
          lib.nameValuePair name {
            hostNames = [ source.host ];
            publicKey = source.hostKey;
          }
        ) (lib.filterAttrs (_: source: source.host != null) backup.enrolled);
        services.syncoid = {
          enable = true;
          interval = [ ];
          user = "root";
          sshKey = "%d/backup-ssh-key";
          service = {
            serviceConfig.LoadCredential = [
              "backup-ssh-key:${config.security.nix-secrets.secrets.stellacode.path}"
            ];
          };
          commonArgs = [
            "--sshoption=StrictHostKeyChecking=yes"
            "--sshoption=UserKnownHostsFile=/etc/ssh/ssh_known_hosts"
          ];
          commands = lib.listToAttrs (
            lib.concatMap (
              sourceName:
              let
                source = backup.enrolled.${sourceName};
              in
              lib.mapAttrsToList (dirName: dir: {
                name = "${sourceName}-${dirName}";
                value = {
                  source = if source.host == null then dir.source else "${source.user}@${source.host}:${dir.source}";
                  target = "${poolName}/${sourceName}/${dir.target}";
                  recursive = true;
                };
              }) source.datasets
            ) (lib.attrNames backup.enrolled)
          );
        };
        users.users = lib.mapAttrs' (
          name: source:
          lib.nameValuePair "backup-${name}" {
            isSystemUser = true;
            group = "backup-${name}";
            shell = pkgs.bash;
            openssh.authorizedKeys.keys = [
              ''command="${pkgs.writeShellScript "backup-request-${name}" "exec ${systemctl} start --wait backup-receive-${name}.service"}",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ${source.publicKey}''
            ];
          }
        ) (lib.filterAttrs (name: _: name != host.name) backup.enrolled);
        users.groups = lib.mapAttrs' (name: _: lib.nameValuePair "backup-${name}" { }) (
          lib.filterAttrs (name: _: name != host.name) backup.enrolled
        );
        security.polkit.extraConfig = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: _: ''
            polkit.addRule(function(action, subject) {
              if (subject.user == "backup-${name}" &&
                  action.id == "org.freedesktop.systemd1.manage-units" &&
                  action.lookup("verb") == "start" &&
                  action.lookup("unit") == "backup-receive-${name}.service") {
                return polkit.Result.YES;
              }
            });
          '') (lib.filterAttrs (name: _: name != host.name) backup.enrolled)
        );
        systemd.services = lib.mapAttrs' (
          name: _:
          lib.nameValuePair "backup-receive-${name}" {
            serviceConfig = {
              Type = "oneshot";
              ExecStart = receive name;
            };
          }
        ) (lib.filterAttrs (name: _: name != host.name) backup.enrolled);
      };
    in
    lib.recursiveUpdate sourceModule receiverModule;
}
