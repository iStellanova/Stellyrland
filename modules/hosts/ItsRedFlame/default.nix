_: {
  flake.modules.nixos.ItsRedFlame-host =
    { host, config, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking.hostName = host.name;

      # Avoids importing a ZFS pool that may already be in use elsewhere.
      boot.zfs.forceImportRoot = false;

      # Own file/recipients — must never decrypt stellyrland's secrets.
      sops.defaultSopsFile = ../../../secrets/ItsRedFlame.yaml;

      hardware.enableRedistributableFirmware = true;

      # This board's tpm_crb probe fails (no working TPM), and systemd's
      # tpm2.target is Wanted-by sysinit.target unconditionally — without
      # this, boot stalls on the 90s device-unit timeout twice (initrd + root).
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
