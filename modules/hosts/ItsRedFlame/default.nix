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

      # Lets stellanova push via --target-host without nix-copy-closure rejecting it.
      nix.settings.trusted-users = [ "stellanova" ];

      hardware.enableRedistributableFirmware = true;

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
