_: {
  flake.modules.nixos.stellyrlab-host =
    { host, pkgs, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking = {
        hostName = host.name;
        networkmanager.enable = true;
      };
      nix.settings.trusted-users = [ host.username ];
      system.stateVersion = "26.05";

      # i915 is unstable on this laptop.
      boot = {
        kernelPackages = pkgs.linuxPackages_6_12;
        blacklistedKernelModules = [ "i915" ];
        zfs = {
          devNodes = "/dev/mapper";
          forceImportRoot = true;
        };
        initrd = {
          supportedFilesystems = [ "zfs" ];
          systemd = {
            enable = true;
            services.zfs-import-zroot = {
              after = [ "systemd-cryptsetup@cryptroot.service" ];
              requires = [ "systemd-cryptsetup@cryptroot.service" ];
            };
          };
          luks.devices.cryptroot = {
            device = "/dev/disk/by-partlabel/disk-main-root";
            allowDiscards = true;
          };
        };
      };

      core.boot.secureBoot = false;
      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };

      hardware.enableRedistributableFirmware = true;
      environment.systemPackages = with pkgs; [
        lm_sensors
        smartmontools
      ];

      # ponytail: single disk; add replication when a destination exists.
      services.sanoid = {
        enable = true;
        datasets = {
          "zroot/safe/home".useTemplate = [ "default" ];
          "zroot/safe/srv".useTemplate = [ "default" ];
        };
        templates.default = {
          hourly = 0;
          daily = 7;
          weekly = 0;
          monthly = 0;
          yearly = 0;
          autosnap = true;
          autoprune = true;
        };
      };
      services.zfs.autoScrub = {
        enable = true;
        interval = "monthly";
        pools = [ "zroot" ];
      };
    };
}
