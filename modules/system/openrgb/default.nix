_: {
  flake.modules.nixos.openrgb = { lib, pkgs, ... }:
    let
      openrgbConfig = pkgs.writeText "OpenRGB.json" (import ./_config.nix { inherit lib; });
    in
    {
      imports = [ ./_boot-service.nix ];

      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
        motherboard = "amd";
      };

      # AF_NETLINK is required by libusb's udev hotplug backend; without it, its
      # socket() call fails and openrgb-1.0rc3 segfaults on startup as root
      # (reproduced 2026-07-14 via systemd-run bisection of this unit's hardening).
      systemd.services.openrgb.serviceConfig.RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];

      # Enable I2C support (required for RAM control and CoolerControl)
      hardware.i2c.enable = true;

      # Link declarative config into the daemon's state directory.
      systemd.tmpfiles.rules = [
        "d /var/lib/OpenRGB 0755 root root -"
        "L+ /var/lib/OpenRGB/OpenRGB.json - - - - ${openrgbConfig}"
      ];
    };

  flake.modules.homeManager.openrgb = { lib, pkgs, ... }:
    let
      openrgbConfig = pkgs.writeText "OpenRGB.json" (import ./_config.nix { inherit lib; });
    in
    {
      xdg.configFile."OpenRGB/OpenRGB.json".source = openrgbConfig;

      programs.zsh.shellAliases = {
        blackout = "openrgb --client 127.0.0.1:6742 --nodetect --color 000000 >/dev/null 2>&1";
        whiteout = "openrgb --client 127.0.0.1:6742 --nodetect --color ffffff >/dev/null 2>&1";
      };
    };
}
