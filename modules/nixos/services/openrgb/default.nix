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

    # Prevent OpenRGB from hanging during boot by blocking its access to the
    # I2C subsystem entirely. Since your devices are USB-based, it doesn't
    # need I2C, and hiding these paths eliminates the 2-minute timeout delay.
    systemd.services.openrgb = {
      serviceConfig = {
        InaccessiblePaths = [
          "/dev/i2c-0" "/dev/i2c-1" "/dev/i2c-2" "/dev/i2c-3" "/dev/i2c-4"
          "/dev/i2c-5" "/dev/i2c-6" "/dev/i2c-7" "/dev/i2c-8" "/dev/i2c-9"
          "/dev/i2c-10" "/sys/bus/i2c" "/sys/class/i2c-dev"
        ];
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      };
    };

    # Enable I2C support (required for CoolerControl, even if OpenRGB doesn't use it)
    hardware.i2c.enable = true;
    boot.kernelModules = [ "i2c-dev" ];

    # Make the optimized config available to the daemon in its state directory
    systemd.tmpfiles.rules = [
      "d /var/lib/OpenRGB 0755 root root -"
      "L+ /var/lib/OpenRGB/OpenRGB.json - - - - ${./OpenRGB.json}"
    ];

    # System-wide service to apply the profile and color on boot
    systemd.services.openrgb-boot-apply = {
      description = "Apply OpenRGB Main Profile and Force White";
      wants = [ "openrgb.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "openrgb-retry-apply" ''
          for i in {1..60}; do
            # 1. Attempt to load the profile
            if ${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect --profile ${./Main.orp} 2>&1 | grep -q "Profile loaded successfully"; then
              # 2. Once loaded, force the color to white
              ${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect --color ffffff >/dev/null 2>&1
              echo "Successfully applied OpenRGB profile and white color on attempt $i."
              exit 0
            fi
            sleep 1
          done
          echo "Failed to apply OpenRGB settings after 60 seconds."
          exit 1
        '';
        RemainAfterExit = true;
      };
    };

    home-manager.users.${identity.name} = {
      # Keep files in user config for GUI access
      xdg.configFile."OpenRGB/OpenRGB.json".source = ./OpenRGB.json;
      xdg.configFile."OpenRGB/Main.orp".source = ./Main.orp;
    };
  };
}
