{ sn, ... }: {
  sn.linux-hardware = {
    includes = [ sn.performance ];
  };

  sn.performance.nixos = { pkgs, ... }: {
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
      # scx_lavd: deadline-based, preferred-core-aware (via amd_pstate=active).
      # Keeps latency-sensitive threads (games) on CCD0 (V-Cache) and throughput on CCD1.
      scheduler = "scx_lavd";
    };
  };
}
