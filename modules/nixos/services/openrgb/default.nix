{ config, lib, pkgs, identity, ... }:

let
  cfg = config.aspects.services.openrgb;
in
{
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
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      };
    };

    # Enable I2C support (required for RAM control and CoolerControl)
    hardware.i2c.enable = true;
    boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

    # Make the optimized config available to the daemon in its state directory
    systemd.tmpfiles.rules = [
      "d /var/lib/OpenRGB 0755 root root -"
      "L+ /var/lib/OpenRGB/OpenRGB.json - - - - ${./OpenRGB.json}"
    ];

    # System-wide service to apply the profile and color on boot
    systemd.services.openrgb-boot-apply = {
      description = "Apply OpenRGB Stellyr Profile and Force White";
      wants = [ "openrgb.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "openrgb-retry-apply" ''
          OPENRGB="${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect"

          # Wait for the server and all 10 device entries to stabilize
          for i in {1..60}; do
            COUNT=$($OPENRGB --list-devices 2>/dev/null | grep -c "Type:" || true)
            if [ "$COUNT" -ge 10 ]; then
              echo "OpenRGB: All hardware detected. Applying global White settings..."

              # 1. Apply the profile
              $OPENRGB --profile ${./Stellyr.orp} >/dev/null 2>&1
              sleep 3

              # 2. Force everything to White globally in one shot
              $OPENRGB --color ffffff >/dev/null 2>&1

              echo "OpenRGB: Global synchronization complete."
              exit 0
            fi
            sleep 1
          done
          echo "OpenRGB: Error - Timed out waiting for hardware."
          exit 1
        '';        RemainAfterExit = true;
      };
    };

    home-manager.users.${identity.name} = {
      # Keep files in user config for GUI access
      xdg.configFile."OpenRGB/OpenRGB.json".source = ./OpenRGB.json;
      xdg.configFile."OpenRGB/Stellyr.orp".source = ./Stellyr.orp;
    };  };
}
