_: {
  config = {
    # NixOS OpenRGB Settings
    flake.modules.nixos.default = {
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
            ExecStart = pkgs.writeShellScript "openrgb-apply" ''
              OPENRGB="${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect"

              MOBO_DONE=0
              LIANLI_DONE=0

              # Poll until all target devices are detected and configured.
              # On boot: waits for USB enumeration. On rebuild: exits immediately.
              # Lian Li SL Infinity: blade zones (0,2,6) = 48 LEDs, mirror zones (1,3,7) = 72 LEDs.
              # Motherboard D_LED2 (zone 1): single Lian Li fan = 40 LEDs.
              for i in {1..120}; do
                DEVICES=$($OPENRGB --list-devices 2>/dev/null)

                if [ "$MOBO_DONE" -eq 0 ]; then
                  MOBO_IDX=$(echo "$DEVICES" | grep -m1 "^[0-9]*: X670 AORUS ELITE AX" | cut -d: -f1)
                  if [ -n "$MOBO_IDX" ]; then
                    $OPENRGB --device "$MOBO_IDX" --zone 1 --size 40 2>/dev/null || true
                    MOBO_DONE=1
                    echo "OpenRGB: Motherboard configured."
                  fi
                fi

                if [ "$LIANLI_DONE" -eq 0 ]; then
                  LIANLI_IDX=$(echo "$DEVICES" | grep -m1 "^[0-9]*: Lian Li Uni Hub - SL Infinity" | cut -d: -f1)
                  if [ -n "$LIANLI_IDX" ]; then
                    for zone in 0 2 6; do
                      $OPENRGB --device "$LIANLI_IDX" --zone $zone --size 48 2>/dev/null || true
                    done
                    for zone in 1 3 7; do
                      $OPENRGB --device "$LIANLI_IDX" --zone $zone --size 72 2>/dev/null || true
                    done
                    LIANLI_DONE=1
                    echo "OpenRGB: Lian Li UNI Hub configured."
                  fi
                fi

                if [ "$MOBO_DONE" -eq 1 ] && [ "$LIANLI_DONE" -eq 1 ]; then
                  break
                fi

                sleep 1
              done

              $OPENRGB --color ffffff >/dev/null 2>&1 || true
              echo "OpenRGB: Done."
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

          programs.zsh.shellAliases = {
            blackout = "openrgb --color 000000";
            whiteout = "openrgb --color ffffff";
          };
        };
      };
    };
  };
}
