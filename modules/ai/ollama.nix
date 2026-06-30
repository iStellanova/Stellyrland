{sn, ...}: {
  sn.ai = {includes = [sn.ollama];};

  sn.ollama.nixos = {pkgs, ...}: {
    services.ollama = {
      enable = true;
      # RX 7900 XTX (Navi 31, gfx1100) — officially supported, no rocmOverrideGfx needed.
      package = pkgs.ollama-rocm;
    };
  };
}
