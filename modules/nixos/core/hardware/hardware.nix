{ config, lib, pkgs, ... }:

{
  options.aspects.core.hardware.enable = lib.mkEnableOption "Core hardware settings" // { default = true; };

  config = lib.mkIf config.aspects.core.hardware.enable {
    environment.systemPackages = [ pkgs.usbutils ];

    # Firmware updates for AMDGPU and other hardware.
    hardware.enableRedistributableFirmware = true;
    # Microcode updates for AMD CPU.
    hardware.cpu.amd.updateMicrocode = true;

    # Enable ROCm/OpenCL support for Radeon 7900 XTX.
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };

    # ZRAM Swap - Compressed swap in RAM to prevent disk thrashing and improve responsiveness.
    zramSwap = {
      enable = true;
      algorithm = "zstd"; # High compression ratio for better RAM utilization
      priority = 100;
      memoryPercent = 100; # Allow ZRAM to use up to 100% of RAM (compressed)
    };

    # fstrim - Trim unused space from SSDs (crucial for NVMe health and performance).
    services.fstrim.enable = true;

    # High-performance optimizations
    # irqbalance - Distribute hardware interrupts across CPU cores.
    # Ananicy - Automated process prioritization for better desktop fluidity.
    # sched-ext - BPF-based CPU schedulers for improved latency and CCD awareness.
    services.irqbalance.enable = true;
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp; # C++ rewrite for lower overhead
      rulesProvider = pkgs.ananicy-rules-cachyos; # Community-vetted performance rules
    };
    services.scx = {
      enable = true;
      scheduler = "scx_rusty"; # Modern Rust-based scheduler with high efficiency
    };
  };
}
