{sn, ...}: {
  sn.linux-hardware = {includes = [sn.performance];};

  sn.performance.nixos = {pkgs, ...}: {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
      memoryPercent = 100;
    };

    services.fstrim.enable = true;
    services.irqbalance.enable = true;

    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    services.scx = {
      enable = true;
      # scx_lavd: deadline-based scheduler, preferred-core-aware via amd_pstate=active.
      # Better than scx_rusty for the 9950X3D's asymmetric CCDs — keeps latency-sensitive
      # threads (games) on CCD0 (V-Cache) and throughput work on CCD1 naturally.
      scheduler = "scx_lavd";
    };
  };
}
