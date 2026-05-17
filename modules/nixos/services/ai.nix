{ config, lib, ... }:

# Echo AI Personality Forge
# Infrastructure (Ollama, Postgres, Bridge) is managed by the external flake:
# github:iStellanova/Project-Echo

let
  cfg = config.aspects.services.ai;
in
{
  options.aspects.services.ai.enable = lib.mkEnableOption "Echo AI Personality Forge";

  config = lib.mkIf cfg.enable {
    # Enable the self-contained service from the external flake with your preferred settings
    aspects.services.echo-ai = {
      enable = true;
      onDemand = true;
      manageInfrastructure = true;
      baseModel = "Echo";
    };

    # ROCm Optimization Suite
    # Targeting the Radeon 7900 XTX (gfx1100) to prevent multi-hour builds.
    nixpkgs.config.rocmTargets = [ "gfx1100" ];
    nixpkgs.overlays = [
      (final: prev: {
        # Force specific GPU targets for the heavy ROCm libraries.
        rocmPackages = prev.rocmPackages.overrideScope (rfinal: rprev: {
          hipblaslt = rprev.hipblaslt.override { gpuTargets = [ "gfx1100" ]; };
          rocblas = rprev.rocblas.override { gpuTargets = [ "gfx1100" ]; };
          rocsparse = rprev.rocsparse.override { gpuTargets = [ "gfx1100" ]; };
          rocsolver = rprev.rocsolver.override { gpuTargets = [ "gfx1100" ]; };
          rocfft = rprev.rocfft.override { gpuTargets = [ "gfx1100" ]; };
        });
      })
    ];
  };
}
