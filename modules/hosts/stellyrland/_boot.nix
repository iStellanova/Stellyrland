{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
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
}
