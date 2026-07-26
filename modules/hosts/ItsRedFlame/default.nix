_: {
  flake.modules.nixos.ItsRedFlame-host =
    { host, config, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking.hostName = host.name;

      # NixOS 26.11's new, safer default — avoids importing a pool that may
      # already be in use elsewhere. No reason to override it here.
      boot.zfs.forceImportRoot = false;

      # Separate encrypted file, own recipient list — ItsRedFlame must
      # never decrypt stellyrland's personal secrets (see secrets/.sops.yaml).
      sops.defaultSopsFile = ../../../secrets/ItsRedFlame.yaml;

      # Lets stellanova push closures via nixos-rebuild --target-host without
      # nix-copy-closure rejecting them as untrusted.
      nix.settings.trusted-users = [ "stellanova" ];

      hardware.enableRedistributableFirmware = true;

      # GTX 1660 (Turing/TU116) — proprietary driver, matches what's already
      # running under Arch. Dual-monitor + Aquamarine (Hyprland's renderer)
      # hit an unfixable nvidia-modeset surface-registration crash across
      # every driver variant tried (595.84, 580.173.02, open kernel module) —
      # that's why this host runs Plasma/KWin instead, which doesn't share
      # that bug.
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.graphics.enable = true;
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
        open = false;
      };
    };
}
