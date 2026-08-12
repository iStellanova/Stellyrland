_: {
  flake.modules.nixos.timecontrol =
    { config, lib, host, pkgs, ... }:
    let
      weekdays = [
        "Monday"
        "Tuesday"
        "Wednesday"
        "Thursday"
        "Friday"
        "Saturday"
        "Sunday"
      ];
      windowType = lib.types.submodule {
        options = {
          start = lib.mkOption {
            type = lib.types.strMatching "([01][0-9]|2[0-3]):[0-5][0-9]";
            description = "Allowed login start time, in HH:MM format.";
          };
          end = lib.mkOption {
            type = lib.types.strMatching "([01][0-9]|2[0-3]):[0-5][0-9]";
            description = "Allowed login end time, in HH:MM format.";
          };
        };
      };
    in
    {
      options.timecontrol = {
        enable = lib.mkEnableOption "declarative user time controls";

        user = lib.mkOption {
          type = lib.types.str;
          default = host.username;
          description = "User whose login schedule will be controlled.";
        };

        schedule = lib.mkOption {
          type = lib.types.attrsOf (lib.types.listOf windowType);
          default = { };
          description = "Allowed login windows keyed by weekday.";
        };
      };

      config = lib.mkIf config.timecontrol.enable {
        assertions = [
          {
            assertion = lib.all (day: builtins.elem day weekdays) (builtins.attrNames config.timecontrol.schedule);
            message = "timecontrol.schedule keys must be weekday names.";
          }
          {
            assertion = lib.all (
              window:
              window.start < window.end
            ) (
              lib.concatLists (lib.attrValues config.timecontrol.schedule)
            );
            message = "timecontrol windows must start before they end; overnight windows are unsupported.";
          }
        ];

        systemd.services = lib.listToAttrs (
          lib.concatLists (
            lib.mapAttrsToList (
              day: windows:
              lib.imap0 (
                index: window:
                {
                  name = "timecontrol-start-${lib.toLower day}-${toString index}";
                  value = {
                    description = "Allow ${config.timecontrol.user} logins on ${day}";
                    serviceConfig = {
                      Type = "oneshot";
                      ExecStart = "${pkgs.shadow}/bin/passwd -u ${lib.escapeShellArg config.timecontrol.user}";
                    };
                  };
                }
              ) windows
            ) config.timecontrol.schedule
          )
          ++ lib.concatLists (
            lib.mapAttrsToList (
              day: windows:
              lib.imap0 (
                index: window:
                {
                  name = "timecontrol-stop-${lib.toLower day}-${toString index}";
                  value = {
                    description = "End ${config.timecontrol.user} login time on ${day}";
                    serviceConfig = {
                      Type = "oneshot";
                      ExecStart = pkgs.writeShellScript "timecontrol-stop-${lib.toLower day}-${toString index}" ''
                        ${pkgs.systemd}/bin/loginctl terminate-user ${lib.escapeShellArg config.timecontrol.user} || true
                        exec ${pkgs.shadow}/bin/passwd -l ${lib.escapeShellArg config.timecontrol.user}
                      '';
                    };
                  };
                }
              ) windows
            ) config.timecontrol.schedule
          )
        );

        systemd.timers = lib.listToAttrs (
          lib.concatLists (
            lib.mapAttrsToList (
              day: windows:
              lib.imap0 (
                index: window:
                {
                  name = "timecontrol-start-${lib.toLower day}-${toString index}";
                  value = {
                    wantedBy = [ "timers.target" ];
                    timerConfig = {
                      OnCalendar = "${day} ${window.start}";
                      Persistent = true;
                    };
                  };
                }
              ) windows
            ) config.timecontrol.schedule
          )
          ++ lib.concatLists (
            lib.mapAttrsToList (
              day: windows:
              lib.imap0 (
                index: window:
                {
                  name = "timecontrol-stop-${lib.toLower day}-${toString index}";
                  value = {
                    wantedBy = [ "timers.target" ];
                    timerConfig = {
                      OnCalendar = "${day} ${window.end}";
                      Persistent = true;
                    };
                  };
                }
              ) windows
            ) config.timecontrol.schedule
          )
        );
      };
    };
}
