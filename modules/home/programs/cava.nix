{
  programs.cava = {
    enable = true;
    settings = {
      general.live-config = 1;
      input.method = "pulse";
      input.source = "auto";
      output.method = "noncurses";
      output.channels = "stereo";
      color.theme = "colors";
      smoothing.noise_reduction = 77;
    };
  };
}
