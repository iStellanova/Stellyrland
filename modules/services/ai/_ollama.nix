{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ai;
in {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    rocmOverrideGfx = "11.0.0";
    environmentVariables = {
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_KEEP_ALIVE = "10m";
    };
    loadModels = lib.mkIf cfg.models.loadOnStartup [
      cfg.models.face
      cfg.models.core
      cfg.models.code
      cfg.models.embed
      cfg.models.draft
      cfg.models.vision
    ];
  };

  nixpkgs.overlays = [
    (_final: prev: {
      ollama-rocm = prev.ollama-rocm.override {
        rocmPackages = prev.rocmPackages.overrideScope (_rfinal: rprev: {
          clr = rprev.clr.override {localGpuTargets = ["gfx1100"];};
        });
      };
    })
  ];

  systemd.services.ollama.wantedBy = lib.mkIf cfg.onDemand (lib.mkForce []);
}
