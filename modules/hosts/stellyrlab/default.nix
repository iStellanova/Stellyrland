{
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
      users.users.${host.username}.linger = true;
      system.stateVersion = "26.05";

      boot = {
        loader.systemd-boot = {
          enable = true;
          configurationLimit = 15;
          consoleMode = "max";
        };
        loader.efi.canTouchEfiVariables = true;
        zfs = {
          devNodes = "/dev/mapper";
          forceImportRoot = true;
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

      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
      };

      hardware.enableRedistributableFirmware = true;
      environment.systemPackages = with pkgs; [
        lm_sensors
        smartmontools
      ];

      # Selective snapshots support local rollback and HDD replication.
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
