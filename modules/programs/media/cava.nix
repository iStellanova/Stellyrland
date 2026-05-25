_: {
  # Darwin Cava Settings
  flake.modules.darwin.cava = _: {
    config = {
      homebrew.brews = ["cava"];
    };
  };

  # Home Manager Cava Settings
  flake.modules.homeManager.cava = {pkgs, ...}: {
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
