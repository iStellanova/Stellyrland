{ pkgs, ... }: {
  home.pointerCursor.hyprcursor.enable = true;
  home.pointerCursor.hyprcursor.size = 16;
  home.packages = [ pkgs.hyprcursor ];
}
