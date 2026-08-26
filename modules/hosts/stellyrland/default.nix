{
  flake-file.inputs.cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  flake.modules.finix.stellyrland-host =
    { modules, pkgs, ... }:
    {
      imports = [
        ./_boot.nix
        ./_coolercontrol-config.nix
      ] ++ (with modules; [
        getty
        polkit
        cron
        nix-daemon
        networkmanager
        openssh
        zfs
        fstrim
      ]);

      finit.runlevel = 3;

      networking = {
        hostName = "stellyrland";
        hostId = "63d11f1d";
      };
      boot = {
        kernelModules = [ "kvm-amd" ];
        initrd.supportedFilesystems = {
          luks.enable = true;
          zfs.enable = true;
        };
        supportedFilesystems = {
          luks.enable = true;
          vfat.enable = true;
          zfs.enable = true;
        };
        initrd.finit.tasks.rollback = {
          conditions = [ "task/zpool-import-zroot/success" ];
          tty = "@console";
          script = ''
            zfs list zroot/local/root@blank >/dev/null 2>&1 && zfs rollback -r zroot/local/root@blank || true
            zfs list zroot/safe/home@blank >/dev/null 2>&1 && zfs rollback -r zroot/safe/home@blank || true
          '';
        };
        initrd.finit.tasks.mount-root.conditions = [ "task/rollback/success" ];
      };

      fileSystems = {
        cryptroot = {
          device = "/dev/disk/by-partlabel/disk-main-root";
          fsType = "luks";
          options = [ "--allow-discards" ];
        };
        cryptextra = {
          device = "/dev/disk/by-partlabel/disk-extra-luks";
          fsType = "luks";
          options = [ "--allow-discards" ];
        };
        "/" = {
          device = "zroot/local/root";
          fsType = "zfs";
          neededForBoot = true;
        };
        "/nix" = {
          device = "zroot/local/nix";
          fsType = "zfs";
          neededForBoot = true;
        };
        "/persist" = {
          device = "zroot/safe/persist";
          fsType = "zfs";
          neededForBoot = true;
        };
        "/home" = {
          device = "zroot/safe/home";
          fsType = "zfs";
        };
        "/ExtraDisk" = {
          device = "zextra/data";
          fsType = "zfs";
          options = [
            "nofail"
            "x-gvfs-show"
            "x-gvfs-name=Extra Disk"
          ];
        };
        "/boot" = {
          device = "/dev/disk/by-label/STELLYRBOOT";
          fsType = "vfat";
          options = [ "fmask=0022" "dmask=0022" ];
        };
      };

      swapDevices = [
        {
          device = "/dev/disk/by-partlabel/disk-main-swap";
          randomEncryption.enable = true;
        }
      ];

      services = {
        cron.enable = true;
        fstrim.enable = true;
        networkmanager.enable = true;
        nix-daemon.enable = true;
        openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
        };
        polkit.enable = true;
        udev.enable = true;
        zfs.autoScrub = {
          enable = true;
          interval = "monthly";
          pools = [
            "zroot"
            "zextra"
          ];
        };
      };

      environment.systemPackages = with pkgs; [
        git
        curl
        wget
      ];
    };
}
