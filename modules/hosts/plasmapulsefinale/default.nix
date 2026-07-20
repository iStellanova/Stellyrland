_: {
  flake.modules.nixos.plasmapulsefinale-host =
    { host, pkgs, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking.hostName = host.name;

      # Separate encrypted file, own recipient list — plasmapulsefinale must
      # never decrypt stellyrland's personal secrets (see secrets/.sops.yaml).
      sops.defaultSopsFile = ../../../secrets/plasmapulsefinale.yaml;

      # Not stellyrland's CachyOS kernel — this CPU's variant (x86_64-v2, no
      # AVX2/BMI/FMA) isn't cached and would compile from source. Stock LTS
      # is a cached fetch, including its zfs module.
      boot.kernelPackages = pkgs.linuxPackages_6_12;

      boot.kernelParams = [
        # 7.7GB total RAM is tight — cap ZFS ARC at 1.5GiB so it doesn't
        # crowd out Plasma + apps.
        "zfs.zfs_arc_max=1610612736"
      ];

      # Legacy BIOS, no EFI at all on this hardware — lanzaboote/systemd-boot
      # (what stellyrland's boot.nix uses) don't apply.
      boot.loader.efi.canTouchEfiVariables = false;
      boot.loader.grub = {
        enable = true;
        devices = [ "/dev/disk/by-id/ata-CT480BX500SSD1_2020E3FB91FD" ];
        zfsSupport = true;
      };

      # NixOS default is true for compat; false is the recommended, safer
      # setting (avoids importing a pool that may already be in use elsewhere).
      boot.zfs.forceImportRoot = false;

      # Sandy Bridge iGPU: needs the legacy VAAPI driver, not intel-media-driver
      # (that one only supports Broadwell/2015+ and later).
      hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-vaapi-driver ];
      };

      # BCM4313 wifi uses the in-tree open-source brcmsmac driver + firmware
      # blobs from linux-firmware — no proprietary broadcom-sta needed.
      hardware.enableRedistributableFirmware = true;

      # Lets stellanova push closures via nixos-rebuild --target-host without
      # nix-copy-closure rejecting them as untrusted.
      nix.settings.trusted-users = [ "stellanova" ];
    };
}
