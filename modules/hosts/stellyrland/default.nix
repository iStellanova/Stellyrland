{ inputs, ... }:
{
  flake-file.inputs.cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

  flake.modules.nixos.stellyrland-host =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
        ./_lact-config.nix
        ./_coolercontrol-config.nix
      ];

      networking.hostName = host.name;

      boot.tmp.useTmpfs = true;
      boot.tmp.tmpfsSize = "50%";

      boot.initrd.compressor = "zstd";
      boot.initrd.compressorArgs = [
        "-19"
        "-T0"
      ];

      boot.initrd.supportedFilesystems = [ "zfs" ];
      boot.zfs.forceImportRoot = true;
      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.emergencyAccess = false;

      boot.initrd.systemd.services."systemd-udevd".serviceConfig = {
        TimeoutStartSec = "30s";
        TimeoutStopSec = "30s";
      };

      boot.initrd.kernelModules = [
        "xhci_pci"
        "usbhid"
        "hid_generic"
        "hid_apple"
        "evdev"
        "aesni_intel"
        "xts"
        "cryptd"
        "dm_crypt"
      ];

      boot.initrd.includeDefaultModules = lib.mkForce false;
      boot.initrd.availableKernelModules = lib.mkForce [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "dm_mod"
        "dm_crypt"
        "aesni_intel"
        "xts"
        "cryptd"
      ];

      boot.initrd.luks.devices."cryptroot" = {
        device = "/dev/disk/by-partlabel/disk-main-root";
        allowDiscards = true;
        crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-pcrs=0+2+7"
        ];
      };

      boot.initrd.luks.devices."cryptextra" = {
        device = "/dev/disk/by-partlabel/disk-extra-luks";
        allowDiscards = true;
        crypttabExtraOpts = [
          "tpm2-device=auto"
          "tpm2-pcrs=0+2+7"
        ];
      };

      fileSystems."/ExtraDisk" = {
        device = "zextra/data";
        fsType = "zfs";
        options = [
          "nofail"
          "x-gvfs-show"
          "x-gvfs-name=Extra Disk"
        ];
      };

      boot.initrd.systemd.services.rollback = {
        description = "Rollback ZFS root and home to blank snapshots";
        wantedBy = [ "initrd.target" ];
        after = [ "zfs-import-zroot.service" ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          if zfs list zroot/local/root@blank > /dev/null 2>&1; then
            zfs rollback -r zroot/local/root@blank
          else
            echo "stellyrland: zroot/local/root@blank not found, skipping root rollback"
          fi

          if zfs list zroot/safe/home@blank > /dev/null 2>&1; then
            zfs rollback -r zroot/safe/home@blank
          else
            echo "stellyrland: zroot/safe/home@blank not found, skipping home rollback"
          fi
        '';
      };

      nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];

      nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
      nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

      boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;
      boot.zfs.package = config.boot.kernelPackages.zfs_cachyos;

      boot.kernelParams = [
        "acpi_enforce_resources=lax"
        "amdgpu.sg_display=0"
        "amdgpu.dc_disable_psr=1"
        "amdgpu.gpu_recovery=1"
        "amd_pstate=active"
        "preempt=full"
        "udev.event-timeout=5"
        "split_lock_detect=off"
        "transparent_hugepage=always"
        "amdgpu.ppfeaturemask=0xffffffff"
        "usbcore.autosuspend=-1"
        "rootdelay=10"
        "nowatchdog"
        "nmi_watchdog=0"
        "threadirqs"
        "audit=0"
      ];

      systemd.tmpfiles.rules = [
        "w /sys/bus/platform/drivers/amd_x3d_vcache/AMDI0101:00/amd_x3d_mode - - - - cache"
        "d /ExtraDisk 0755 ${host.username} users -"
      ];

      services.sanoid = {
        enable = true;
        datasets = {
          "zroot/safe/home".useTemplate = [ "default" ];
          "zroot/safe/persist".useTemplate = [ "default" ];
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
        pools = [
          "zroot"
          "zextra"
        ];
      };

      hardware.amdgpu.initrd.enable = false;
      hardware.enableRedistributableFirmware = true;
      hardware.cpu.amd.updateMicrocode = true;
      environment.systemPackages = [ pkgs.usbutils ];
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
          rocmPackages.clr
        ];
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        swapDevices = 1;
        priority = 100;
        memoryPercent = 100;
      };

      services.fstrim.enable = true;
      services.irqbalance.enable = true;

      services.ananicy = {
        enable = true;
        # Remove when an ananicy-cpp release includes these standard headers.
        package = pkgs.ananicy-cpp.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            sed -i '1i#include <cstdint>' src/platform/linux/backtrace.cpp
            sed -i '1i#include <cstring>' src/utility/argument_parsing/argument.cpp
            sed -i '1i#include <cstring>' src/platform/linux/singleton_process.cpp
          '';
        });
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };

      services.scx = {
        enable = true;
        # LAVD favors latency-sensitive threads on the X3D CCD.
        scheduler = "scx_lavd";
      };

      desktop = {
        gaming.hdr.enable = host.features.hdr;

        hyprland = {
          wallpaperEngine = {
            steamLibrary = "/ExtraDisk";
            workshopId = "3258032485";
            screenRoots = host.monitorPriority;
          };

          hyprsplit = {
            inherit (host) monitorPriority;
            numWorkspaces = 7;
          };

          monitors = [
            {
              output = lib.elemAt host.monitorPriority 0;
              mode = "3440x1440@175";
              position = "1440x541";
              scale = 1;
              bitdepth = 10;
              cm = "hdr";
              supports_wide_color = 1;
              sdr_min_luminance = 0.0;
              sdr_max_luminance = 203;
              sdrbrightness = 0.75;
              sdrsaturation = 1.2;
              min_luminance = 0.0005;
              max_luminance = 1000;
              max_avg_luminance = 250;
            }
            {
              output = lib.elemAt host.monitorPriority 1;
              mode = "2560x1440@100";
              position = "0x0";
              scale = 1;
              transform = 1;
              bitdepth = 10;
              cm = "srgb";
              sdr_min_luminance = 0.2;
              min_luminance = 0.25;
              max_luminance = 250;
              max_avg_luminance = 250;
            }
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = 1;
            }
          ];
        };
      };
    };
}
