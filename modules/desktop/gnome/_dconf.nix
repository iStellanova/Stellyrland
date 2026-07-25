_: {
  # lockAll so these survive a family member poking around in Settings —
  # nixos-rebuild switch is the only thing that gets to change them.
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
}
