_: {
  flake.modules.nixos.stellyrstick-host =
    { host, ... }:
    {
      imports = [
        ./_hardware-configuration.nix
        ./_disko-config.nix
      ];

      networking.hostName = host.name;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = false;
      hardware.enableRedistributableFirmware = true;
    };
}
