{ pkgs, ... }: {
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 16;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
    hyprcursor.size = 16;
  };
  home.packages = [ pkgs.hyprcursor ];
}
