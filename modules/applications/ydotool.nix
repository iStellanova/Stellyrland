{
  modules.nixos.ydotool = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ydotool ];
  };
}
