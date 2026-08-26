{
  flake.modules.nixos.openrgb =
    { lib, pkgs, ... }:
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

  flake.modules.finix.openrgb =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      openrgbConfig = pkgs.writeText "OpenRGB.json" (import ./_config.nix { inherit lib; });
    in
    {
      imports = [
        inputs.finix-community-modules.nixosModules.openrgb
        inputs.self.modules.finix.openrgb-boot-service
      ];

      services.hardware.openrgb = {
        enable = true;
        package = pkgs.openrgb-with-all-plugins;
        motherboard = "amd";
      };

      finit.tmpfiles.rules = [
        "d /var/lib/OpenRGB 0755 root root -"
        "L+ /var/lib/OpenRGB/OpenRGB.json - - - - ${openrgbConfig}"
      ];
    };

  flake.modules.finix.openrgb-boot-service =
    { pkgs, ... }:
    let
      openrgb = "${pkgs.openrgb-with-all-plugins}/bin/openrgb --client 127.0.0.1:6742 --nodetect";
      apply = pkgs.writeShellScript "openrgb-apply" ''
        for i in {1..120}; do
          devices="$(${openrgb} --list-devices 2>/dev/null)"
          mobo=$(printf '%s\n' "$devices" | sed -n 's/^\([0-9]*\): X670 AORUS ELITE AX$/\1/p')
          lianli=$(printf '%s\n' "$devices" | sed -n 's/^\([0-9]*\): Lian Li Uni Hub - SL Infinity$/\1/p')
          dram=$(printf '%s\n' "$devices" | sed -n 's/^\([0-9]*\): ENE DRAM$/\1/p')
          [ -n "$mobo" ] && for idx in $mobo; do ${openrgb} --device "$idx" --zone 1 --size 40 --color ffffff || true; done
          [ -n "$lianli" ] && for idx in $lianli; do ${openrgb} --device "$idx" --zone 0 --size 48 --color ffffff --zone 1 --size 72 --color ffffff --zone 2 --size 48 --color ffffff --zone 3 --size 72 --color ffffff --zone 4 --size 48 --color ffffff --zone 5 --size 72 --color ffffff --zone 6 --size 48 --color ffffff --zone 7 --size 72 --color ffffff || true; done
          [ -n "$dram" ] && for idx in $dram; do ${openrgb} --device "$idx" --mode static || true; done
          [ -n "$mobo" ] && [ -n "$lianli" ] && [ -n "$dram" ] && break
          sleep 1
        done
        ${openrgb} --color ffffff || true
      '';
      blackout = pkgs.writeShellScript "openrgb-shutdown-blackout" ''
        ${openrgb} --color 000000 || true
        sleep 2
      '';
    in
    {
      finit.services.openrgb-boot-apply = {
        description = "Apply OpenRGB settings";
        conditions = "service/openrgb/ready";
        command = apply;
        stop = blackout;
        runlevels = "2345";
      };
    };

  flake.modules.homeManager.openrgb =
    { lib, pkgs, ... }:
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
