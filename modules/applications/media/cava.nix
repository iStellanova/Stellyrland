_: {
  flake.modules.homeManager.cava = { pkgs, ... }: {
    programs.cava = {
      enable = true;
      settings = {
        general.live-config = 1;
        input.method = if pkgs.stdenv.isDarwin then "portaudio" else "pulse";
        input.source = "auto";
        output.method = "noncurses";
        output.channels = "stereo";
        smoothing.noise_reduction = 77;
      };
    };
  };
}
