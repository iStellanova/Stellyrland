{
  flake.modules.nixos.plasmapulsefinale-host =
    { host, pkgs, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking.hostName = host.name;

      # Stock LTS is cached with ZFS; this CPU's CachyOS variant is not.
      boot.kernelPackages = pkgs.linuxPackages_6_12;

      boot.kernelParams = [
        # Keep ZFS ARC from crowding out Plasma on 7.7GB RAM.
        "zfs.zfs_arc_max=1610612736"
      ];

      # Legacy BIOS; use GRUB rather than systemd-boot.
      boot.loader.efi.canTouchEfiVariables = false;
      boot.loader.grub = {
        enable = true;
        devices = [ "/dev/disk/by-id/ata-CT480BX500SSD1_2020E3FB91FD" ];
        zfsSupport = true;
      };

      # Avoid importing a pool that may already be in use elsewhere.
      boot.zfs.forceImportRoot = false;

      # Sandy Bridge needs the legacy VAAPI driver, not intel-media-driver.
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-vaapi-driver ];
      };

      # BCM4313 uses brcmsmac and linux-firmware; no proprietary driver.
      hardware.enableRedistributableFirmware = true;
    };
}
