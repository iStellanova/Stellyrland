_: {
  flake.modules.nixos.performance = { pkgs, ... }: {
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
      # TODO: Remove this upstream workaround once an ananicy-cpp release includes the missing standard headers.
      package = pkgs.ananicy-cpp.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          sed -i '1i#include <cstdint>' src/platform/linux/backtrace.cpp
          sed -i '1i#include <cstring>' src/utility/argument_parsing/argument.cpp
          sed -i '1i#include <cstring>' src/platform/linux/singleton_process.cpp
        '';
      });
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
