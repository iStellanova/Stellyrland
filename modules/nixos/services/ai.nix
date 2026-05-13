{ config, lib, pkgs, ... }:

let
  cfg = config.aspects.services.ai;
in
{
  options.aspects.services.ai.enable = lib.mkEnableOption "Local AI services (Ollama)";

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "11.0.0"; # Necessary for RX 7900 XTX (Navi 31)
    };

    # Ensure python3 and requests are available for the bridge script
    # We add them to systemPackages so they are available to the user.
    environment.systemPackages = with pkgs; [
      (python3.withPackages (ps: with ps; [
        requests
      ]))
    ];
  };
}
