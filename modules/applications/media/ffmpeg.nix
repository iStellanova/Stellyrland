{
  modules.nixos.ffmpeg = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ffmpeg ];
  };
}
