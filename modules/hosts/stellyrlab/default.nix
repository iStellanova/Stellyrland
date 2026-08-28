{
  flake.modules.nixos.stellyrlab-host =
    {
      config,
      host,
      pkgs,
      ...
    }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking = {
        hostName = host.name;
        networkmanager = {
          enable = true;
          ensureProfiles.profiles.stellyrland-direct = {
            connection = {
              id = "stellyrland-direct";
              type = "ethernet";
              interface-name = "eno2";
            };
            ipv4 = {
              method = "manual";
              addresses = "172.31.255.1/30";
            };
            ipv6.method = "disabled";
          };
        };
      };
      nix.settings = {
        trusted-users = [ host.username ];
        max-jobs = 2;
        cores = 4;
      };
      users.users.${host.username}.linger = true;
      system.stateVersion = "26.05";

      boot = {
        kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3;
        zfs = {
          package = config.boot.kernelPackages.zfs_cachyos;
          devNodes = "/dev/mapper";
          forceImportRoot = true;
        };
        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 15;
            consoleMode = "max";
          };
          efi.canTouchEfiVariables = true;
        };
        initrd = {
          supportedFilesystems = [ "zfs" ];
          systemd.enable = true;
          luks.devices.stellyrlab-root = {
            device = "/dev/disk/by-partlabel/disk-main-root";
            allowDiscards = true;
            crypttabExtraOpts = [
              "tpm2-device=auto"
              "tpm2-pcrs=0+2+7"
            ];
          };
        };
      };

      services = {
        logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchExternalPower = "ignore";
        };

        # Selective snapshots support local rollback and HDD replication.
        sanoid = {
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
        zfs.autoScrub = {
          enable = true;
          interval = "monthly";
          pools = [ "zroot" ];
        };
      };

      hardware.enableRedistributableFirmware = true;
      environment.systemPackages = with pkgs; [
        lm_sensors
        smartmontools
        wakeonlan
      ];

    };
}
