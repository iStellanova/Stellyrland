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
    services.echo-ai.enable = true;
  };
}
