{ config, lib, pkgs, ... }:

{
  options.aspects.core.networking.enable = lib.mkEnableOption "Core networking services (Tailscale)" // { default = true; };

  config = lib.mkIf config.aspects.core.networking.enable {
    # Tailscale service
    # On NixOS, this enables the daemon and CLI.
    # On Darwin, this enables the tailscale service.
    services.tailscale = {
      enable = true;
      interfaceName = "userspace-networking";
      useRoutingFeatures = "none";
      extraUpFlags = [
        "--accept-dns=false"
        "--accept-routes=false"
        "--ssh"
      ];
    };

    # Add tailscale to system packages to ensure the CLI is always available
    environment.systemPackages = [ pkgs.tailscale ];
  };
}
