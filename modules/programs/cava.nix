{ config, lib, ... }:
{
  options.aspects.programs.cava.enable = lib.mkEnableOption "Cava";
  config = lib.mkIf config.aspects.programs.cava.enable {
    home-manager.users.stellanova = {
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
    };
  };
}
