_: {
  sn.openrgb.nixos = { pkgs, ... }: {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
      motherboard = "amd";
    };

    # Allow OpenRGB to access I2C for RAM control.
    systemd.services.openrgb = {
      serviceConfig = {
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
      };
    };

    # Enable I2C support (required for RAM control and CoolerControl)
    hardware.i2c.enable = true;
    boot.kernelModules = [
      "i2c-dev"
      "i2c-piix4"
    ];

    # Make the optimized config available to the daemon in its state directory
    systemd.tmpfiles.rules = [
      "d /var/lib/OpenRGB 0755 root root -"
      "L+ /var/lib/OpenRGB/OpenRGB.json - - - - ${./OpenRGB.json}"
    ];

    # System-wide service to apply the configuration on boot, and turn off on shutdown
    systemd.services.openrgb-boot-apply = {
      description = "Apply OpenRGB Declarative Settings and Force White / Black on Shutdown";
      requires = [ "openrgb.service" ];
      after = [ "openrgb.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "openrgb-apply" ''
          OPENRGB="${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect"

          MOBO_DONE=0
          LIANLI_DONE=0
          DRAM_DONE=0

          # Poll until all target devices are detected and configured.
          # On boot: waits for USB enumeration. On rebuild: exits immediately.
          for i in {1..120}; do
            DEVICES=$($OPENRGB --list-devices 2>/dev/null)

            if [ "$MOBO_DONE" -eq 0 ]; then
              MOBO_INDICES=$(echo "$DEVICES" | grep "^[0-9]*: X670 AORUS ELITE AX" | cut -d: -f1)
              if [ -n "$MOBO_INDICES" ]; then
                for idx in $MOBO_INDICES; do
                  # Only resize if not already sized (checks for presence of LED 39 in devices list)
                  if echo "$DEVICES" | grep -q "LED Strip 2 LED 39"; then
                    echo "OpenRGB: Motherboard index $idx already sized."
                  else
                    $OPENRGB --device "$idx" --zone 1 --size 40 --color ffffff 2>/dev/null || true
                  fi
                done
                MOBO_DONE=1
                echo "OpenRGB: Motherboard configured."
              fi
            fi

            if [ "$LIANLI_DONE" -eq 0 ]; then
              LIANLI_INDICES=$(echo "$DEVICES" | grep "^[0-9]*: Lian Li Uni Hub - SL Infinity" | cut -d: -f1)
              if [ -n "$LIANLI_INDICES" ]; then
                for idx in $LIANLI_INDICES; do
                  # Only resize if not already sized (checks for presence of Channel 8, LED 72 in devices list)
                  if echo "$DEVICES" | grep -q "Channel 8, LED 72"; then
                    echo "OpenRGB: Lian Li UNI Hub index $idx already sized."
                  else
                    # Configure and size all 8 zones in a single chained command to prevent flashing/dancing
                    $OPENRGB --device "$idx" \
                      --zone 0 --size 48 --color ffffff \
                      --zone 1 --size 72 --color ffffff \
                      --zone 2 --size 48 --color ffffff \
                      --zone 3 --size 72 --color ffffff \
                      --zone 4 --size 48 --color ffffff \
                      --zone 5 --size 72 --color ffffff \
                      --zone 6 --size 48 --color ffffff \
                      --zone 7 --size 72 --color ffffff 2>/dev/null || true
                  fi
                done
                LIANLI_DONE=1
                echo "OpenRGB: Lian Li UNI Hub configured."
              fi
            fi

            if [ "$DRAM_DONE" -eq 0 ]; then
              DRAM_INDICES=$(echo "$DEVICES" | grep "^[0-9]*: ENE DRAM" | cut -d: -f1)
              if [ -n "$DRAM_INDICES" ]; then
                for idx in $DRAM_INDICES; do
                  $OPENRGB --device "$idx" --mode static 2>/dev/null || true
                done
                DRAM_DONE=1
                echo "OpenRGB: DRAM configured."
              fi
            fi

            if [ "$MOBO_DONE" -eq 1 ] && [ "$LIANLI_DONE" -eq 1 ] && [ "$DRAM_DONE" -eq 1 ]; then
              break
            fi

            sleep 1
          done

          $OPENRGB --color ffffff >/dev/null 2>&1 || true
          echo "OpenRGB: Configuration applied successfully."
        '';
        ExecStop = pkgs.writeShellScript "openrgb-shutdown-blackout" ''
          OPENRGB="${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect"
          echo "OpenRGB: Turning off lights for shutdown..."
          DEVICES=$($OPENRGB --list-devices 2>/dev/null)
          for idx in $(echo "$DEVICES" | grep "^[0-9]*: ENE DRAM" | cut -d: -f1); do
            $OPENRGB --device "$idx" --mode static 2>/dev/null || true
          done
          $OPENRGB --color 000000 >/dev/null 2>&1
          sleep 2
        '';
        RemainAfterExit = true;
      };
    };
  };

  sn.openrgb.homeManager = _: {
    xdg.configFile."OpenRGB/OpenRGB.json".source = ./OpenRGB.json;

    programs.zsh.shellAliases = {
      blackout = "openrgb --client 127.0.0.1:6742 --nodetect --color 000000 >/dev/null 2>&1";
      whiteout = "openrgb --client 127.0.0.1:6742 --nodetect --color ffffff >/dev/null 2>&1";
    };
  };
}
