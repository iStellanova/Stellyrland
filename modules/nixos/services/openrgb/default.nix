{
  config,
  lib,
  pkgs,
  identity,
  ...
}: let
  cfg = config.aspects.services.openrgb;
in {
  options.aspects.services.openrgb.enable = lib.mkEnableOption "OpenRGB service";

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      motherboard = "amd";
    };

    # Allow OpenRGB to access I2C for RAM control.
    systemd.services.openrgb = {
      serviceConfig = {
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
      };
    };

    # Enable I2C support (required for RAM control and CoolerControl)
    hardware.i2c.enable = true;
    boot.kernelModules = ["i2c-dev" "i2c-piix4"];

    # Make the optimized config available to the daemon in its state directory
    systemd.tmpfiles.rules = [
      "d /var/lib/OpenRGB 0755 root root -"
      "L+ /var/lib/OpenRGB/OpenRGB.json - - - - ${./OpenRGB.json}"
    ];

    # System-wide service to apply the profile and color on boot, and turn off on shutdown
    systemd.services.openrgb-boot-apply = {
      description = "Apply OpenRGB Stellyr Profile and Force White / Black on Shutdown";
      requires = ["openrgb.service"];
      after = ["openrgb.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "openrgb-retry-apply" ''
          OPENRGB="${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect"

          # Wait for the server to detect at least one device (I2C/RAM arrives first)
          for i in {1..60}; do
            COUNT=$($OPENRGB --list-devices 2>/dev/null | grep -c "Type:" || true)
            if [ "$COUNT" -ge 1 ]; then
              echo "OpenRGB: $COUNT device(s) detected. Applying profile and white..."
              $OPENRGB --profile ${./stellyr.orp} >/dev/null 2>&1 || true
              sleep 2
              $OPENRGB --color ffffff >/dev/null 2>&1 || true
              echo "OpenRGB: First pass complete. Waiting for USB controllers..."
              break
            fi
            sleep 1
          done

          # Second pass after 30s: catches USB fan controllers (NZXT, etc.)
          # that finish enumerating after I2C devices like RAM sticks.
          sleep 30
          $OPENRGB --color ffffff >/dev/null 2>&1 || true
          echo "OpenRGB: Second pass complete."
        '';
        ExecStop = pkgs.writeShellScript "openrgb-shutdown-blackout" ''
          OPENRGB="${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect"
          echo "OpenRGB: Turning off lights for shutdown..."
          $OPENRGB --color 000000 >/dev/null 2>&1
          sleep 2
        '';
        RemainAfterExit = true;
      };
    };

    home-manager.users.${identity.name} = {
      # Keep files in user config for GUI access
      xdg.configFile."OpenRGB/OpenRGB.json".source = ./OpenRGB.json;
      xdg.configFile."OpenRGB/stellyr.orp".source = ./stellyr.orp;

      programs.zsh.shellAliases = {
        blackout = "openrgb --color 000000";
        whiteout = "openrgb --color ffffff";
      };
    };
  };
}
