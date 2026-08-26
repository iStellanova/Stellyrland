{
  flake-file.inputs.cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  flake.modules.finix.stellyrland-host =
    { modules, pkgs, ... }:
    {
      imports = [
        ./_boot.nix
        ./_hardware-configuration.nix
        ./_storage.nix
        ./_lact-config.nix
        ./_coolercontrol-config.nix
        ./_desktop.nix
      ]
      ++ (with modules; [
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

      environment.etc."NetworkManager/system-connections/stellyrlab-direct.nmconnection" = {
        mode = "0600";
        text = ''
          [connection]
          id=stellyrlab-direct
          type=ethernet
          interface-name=enp16s0
          autoconnect=true

          [ipv4]
          method=manual
          address1=172.31.255.2/30

          [ipv6]
          method=disabled
        '';
      };

      boot = {
        kernelModules = [
          "kvm-amd"
          "zram"
        ];
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
          options = [
            "fmask=0022"
            "dmask=0022"
          ];
        };
      };

      swapDevices = [
        {
          device = "/dev/disk/by-partlabel/disk-main-swap";
          randomEncryption.enable = true;
        }
      ];

      environment.systemPackages = with pkgs; [
        usbutils
        git
        curl
        wget
      ];
      hardware.firmware = [ pkgs.linux-firmware ];
      hardware.cpu.amd.updateMicrocode = true;

      finit.tmpfiles.rules = [
        "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
      ];

      environment.etc."ananicy.d".source = "${pkgs.ananicy-rules-cachyos}/etc/ananicy.d";
      finit.services.irqbalance = {
        description = "IRQ balancing daemon";
        command = "${pkgs.irqbalance}/bin/irqbalance --foreground";
      };
      finit.services.ananicy-cpp = {
        description = "Ananicy process manager";
        command = "${pkgs.ananicy-cpp}/bin/ananicy-cpp start";
      };
      finit.tasks.zram = {
        description = "Configure compressed RAM swap";
        runlevels = "S";
        command = pkgs.writeShellScript "zram-setup" ''
          ${pkgs.kmod}/bin/modprobe zram
          size=$(( $(awk '/MemTotal:/ { print $2 }' /proc/meminfo) * 1024 ))
          ${pkgs.util-linux}/bin/zramctl --find --size "$size" /dev/zram0
          ${pkgs.util-linux}/bin/mkswap -L zram0 /dev/zram0
          ${pkgs.util-linux}/bin/swapon --priority 100 /dev/zram0
        '';
      };

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

    };
}
