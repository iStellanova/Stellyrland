{
  flake.modules.nixos.ItsRedFlame-host =
    { host, config, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking.hostName = host.name;
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      timecontrol.enable = true;
      timecontrol.schedule = {
        Monday = [
          {
            start = "16:00";
            end = "18:00";
          }
        ];
        Tuesday = [
          {
            start = "16:00";
            end = "18:00";
          }
        ];
        Wednesday = [
          {
            start = "16:00";
            end = "18:00";
          }
        ];
        Thursday = [
          {
            start = "16:00";
            end = "18:00";
          }
        ];
        Friday = [
          {
            start = "16:00";
            end = "18:00";
          }
        ];
        Saturday = [
          {
            start = "10:00";
            end = "12:00";
          }
          {
            start = "16:00";
            end = "18:00";
          }
        ];
        Sunday = [
          {
            start = "10:00";
            end = "12:00";
          }
          {
            start = "16:00";
            end = "18:00";
          }
        ];
      };

      # Avoid ZFS pool import conflicts.
      boot.zfs.forceImportRoot = false;

      # Use this host's SOPS file and recipients.
      sops.defaultSopsFile = ../../../secrets/ItsRedFlame.yaml;

      hardware.enableRedistributableFirmware = true;
      myModules.programs.obs.nvidia = true;

      # Broken TPM probe; without this, boot stalls twice for 90s.
      systemd.tpm2.enable = false;
      boot.initrd.systemd.tpm2.enable = false;

      # GTX 1660 (Turing) — proprietary driver. Runs Plasma/KWin rather than
      # Hyprland: Aquamarine hit an unfixable dual-monitor crash on this GPU.
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.graphics.enable = true;
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
        open = false;
      };
    };
}
