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
    # Enable the self-contained service from the external flake
    aspects.services.echo-ai.enable = true;

    # ROCm Optimization Suite
    # Targeting the Radeon 7900 XTX (gfx1100) to prevent multi-hour builds.
    nixpkgs.config.rocmTargets = [ "gfx1100" ];

    nixpkgs.overlays = [
      (final: prev: {
        # Force specific GPU targets for the heavy ROCm libraries.
        # This ensures that even if the global config is bypassed, these packages
        # will strictly adhere to the gfx1100 architecture.
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
