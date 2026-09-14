{
  modules.nixos.ItsRedFlame-host =
    { host, config, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking.hostName = host.name;
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Avoid ZFS pool import conflicts.
      boot.zfs.forceImportRoot = false;

      hardware.enableRedistributableFirmware = true;
      myModules.programs.obs.nvidia = true;

      # Broken TPM probe; without this, boot stalls twice for 90s.
      systemd.tpm2.enable = false;
      boot.initrd.systemd.tpm2.enable = false;

      # GTX 1660 (Turing) — proprietary driver.
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.graphics.enable = true;
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
        open = false;
      };
    };
}
