{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}: {
  options.aspects.core.networking.enable = lib.mkEnableOption "Core networking services (Tailscale)";

  config = lib.mkIf config.aspects.core.networking.enable {
    # Tailscale service
    # On NixOS, this enables the daemon and CLI.
    # On Darwin, this enables the tailscale service.
    services.tailscale =
      {
        enable = true;
      }
      // lib.optionalAttrs (!isDarwin) {
        useRoutingFeatures = "none";
        extraUpFlags = [
          "--accept-dns=false"
          "--accept-routes=false"
        ];
      };

    # Add tailscale to system packages to ensure the CLI is always available
    environment.systemPackages = with pkgs; [
      tailscale
      wget
    ];
  };
}
