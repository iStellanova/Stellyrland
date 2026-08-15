_:
{
  flake.modules.nixos.gnome =
    { pkgs, ... }:
    {
      imports = [
        ./_dconf.nix
      ];

      environment.systemPackages = [ pkgs.gnomeExtensions.dash-to-dock ];

      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;

      services.printing.enable = true;
    };
}
