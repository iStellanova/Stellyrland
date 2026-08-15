_:
{
  flake.modules.nixos.gnome =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.gnomeExtensions.dash-to-dock ];

      services.desktopManager.gnome.enable = true;
      services.displayManager.gdm.enable = true;

      services.printing.enable = true;

      programs.dconf.profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/wm/preferences" = {
              button-layout = "appmenu:minimize,maximize,close";
            };
            "org/gnome/shell" = {
              enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];
            };
            "org/gnome/shell/extensions/dash-to-dock" = {
              dock-position = "BOTTOM";
              dock-fixed = true;
              autohide = false;
              intellihide = false;
              extend-height = false;
            };
          };
          lockAll = true;
        }
      ];
    };
}
