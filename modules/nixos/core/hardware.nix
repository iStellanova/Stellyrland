{ config, lib, pkgs, ... }:

{
  options.aspects.core.hardware.enable = lib.mkEnableOption "Core hardware settings" // { default = true; };

  config = lib.mkIf config.aspects.core.hardware.enable {
    environment.systemPackages = [ pkgs.usbutils ];

    # Firmware updates for AMDGPU and other hardware.
    hardware.enableRedistributableFirmware = true;
    # Microcode updates for AMD CPU.
    hardware.cpu.amd.updateMicrocode = true;

    # ZRAM Swap - Compressed swap in RAM to prevent disk thrashing and improve responsiveness.
    zramSwap = {
      enable = true;
      algorithm = "zstd"; # High compression ratio for better RAM utilization
      priority = 100;
    };

    # fstrim - Trim unused space from SSDs (crucial for NVMe health and performance).
    services.fstrim.enable = true;

    # High-performance optimizations
    # irqbalance - Distribute hardware interrupts across CPU cores.
    # Ananicy - Automated process prioritization for better desktop fluidity.
    services.irqbalance.enable = true;
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp; # C++ rewrite for lower overhead
      rulesProvider = pkgs.ananicy-rules-cachyos; # Community-vetted performance rules
    };
  };
}
