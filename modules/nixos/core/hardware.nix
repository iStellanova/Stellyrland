{ config, lib, pkgs, ... }:

{
  options.aspects.core.hardware.enable = lib.mkEnableOption "Core hardware settings" // { default = true; };

  config = lib.mkIf config.aspects.core.hardware.enable {
    environment.systemPackages = [ pkgs.usbutils ];

    # Firmware updates for AMDGPU and other hardware.
    hardware.enableRedistributableFirmware = true;
    # Microcode updates for AMD CPU.
    hardware.cpu.amd.updateMicrocode = true;

    # ZRAM Swap - Zstandard compression for swap space.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
    };

    # fstrim - Trim unused space from SSDs.
    services.fstrim.enable = true;

    # High-performance optimizations
    # irqbalance - Distribute IRQs across CPU cores.
    # Ananicy - Advanced task scheduling.
    services.irqbalance.enable = true;
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
  };
}
