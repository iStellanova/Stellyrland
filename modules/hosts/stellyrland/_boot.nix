{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cachyPkgs = pkgs.extend inputs.cachyos-kernel.overlays.pinned;
  kernelPackages = cachyPkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;
  zfsPackage = kernelPackages.zfs_cachyos;
  clevis = "${pkgs.clevis}/bin/clevis";
  cryptsetup = "${pkgs.cryptsetup}/bin/cryptsetup";
in
{
  boot.kernelPackages = kernelPackages;

  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [
    "-19"
    "-T0"
  ];
  boot.initrd.supportedFilesystems = {
    luks.enable = true;
    zfs = {
      enable = true;
      packages = [ zfsPackage ];
    };
  };
  boot.supportedFilesystems = {
    luks.enable = true;
    vfat.enable = true;
    zfs = {
      enable = true;
      packages = [ zfsPackage ];
    };
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
  boot.initrd.availableKernelModules = [
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
  fileSystems."/tmp" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "size=50%" ];
  };

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
  boot.initrd.path = [
    pkgs.clevis
    pkgs.tpm2-tss
  ];
  boot.initrd.finit.tasks.luks = lib.mkForce {
    conditions = [
      "task/wait-dev-dev-disk-by-partlabel-disk-main-root/success"
      "task/wait-dev-dev-disk-by-partlabel-disk-extra-luks/success"
    ];
    tty = "@console";
    script = ''
      unlock() {
        name="$1"
        device="$2"
        if ! ${clevis} luks unlock -d "$device" -n "$name"; then
          ${cryptsetup} open --allow-discards "$device" "$name"
        fi
      }
      unlock cryptroot /dev/disk/by-partlabel/disk-main-root
      unlock cryptextra /dev/disk/by-partlabel/disk-extra-luks
    '';
  };
  boot.initrd.finit.tasks.rollback = {
    conditions = [ "task/zpool-import-zroot/success" ];
    tty = "@console";
    script = ''
      zfs list zroot/local/root@blank >/dev/null 2>&1 && zfs rollback -r zroot/local/root@blank || true
      zfs list zroot/safe/home@blank >/dev/null 2>&1 && zfs rollback -r zroot/safe/home@blank || true
    '';
  };
}
