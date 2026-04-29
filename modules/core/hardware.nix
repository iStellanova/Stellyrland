{ config, lib, pkgs, ... }:

{
  options.aspects.core.hardware.enable = lib.mkEnableOption "Core hardware settings" // { default = true; };

  config = lib.mkIf config.aspects.core.hardware.enable {
    environment.systemPackages = [ pkgs.usbutils ];

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;

    # ZRAM Swap
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
    };

    # SSD Maintenance
    services.fstrim.enable = true;

    # High-performance optimizations
    services.irqbalance.enable = true;
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
  };
}
