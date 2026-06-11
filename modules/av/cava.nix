{sn, ...}: {
  sn.av = {includes = [sn.cava];};

  sn.cava.darwin = _: {
    homebrew.brews = ["cava"];
  };

  sn.cava.homeManager = {pkgs, ...}: {
    programs.cava = {
      enable = true;
      settings = {
        general.live-config = 1;
        input.method =
          if pkgs.stdenv.isDarwin
          then "portaudio"
          else "pulse";
        input.source = "auto";
        output.method = "noncurses";
        output.channels = "stereo";
        color.theme = "colors";
        smoothing.noise_reduction = 77;
      };
    };
  };
}
