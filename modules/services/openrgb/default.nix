{ config, lib, pkgs, ... }:

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

    # Enable I2C support (required for many RAM and Motherboard RGB controllers)
    hardware.i2c.enable = true;

    # Ensure the package is available in the system environment
    environment.systemPackages = [
      pkgs.openrgb-with-all-plugins
    ];

    home-manager.users.stellanova = {
      xdg.configFile."OpenRGB/OpenRGB.json".source = ./OpenRGB.json;
      xdg.configFile."OpenRGB/Main.orp".source = ./Main.orp;

      # Automatically load the "Main" profile AND force pure white on login
      systemd.user.services.openrgb-load-profile = {
        Unit = {
          Description = "Load OpenRGB Main Profile and Force White";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          # Load the profile first, then force all devices to pure white (FFFFFF)
          ExecStart = "${pkgs.openrgb-with-all-plugins}/bin/bash -c '${pkgs.openrgb-with-all-plugins}/bin/openrgb --profile Main.orp && sleep 2 && ${pkgs.openrgb-with-all-plugins}/bin/openrgb --color ffffff'";
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
