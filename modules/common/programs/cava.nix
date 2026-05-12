{ config, lib, identity, isDarwin, ... }:
{
  options.aspects.programs.cava.enable = lib.mkEnableOption "Cava";
  config = lib.mkIf config.aspects.programs.cava.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.brews = [ "cava" ];
    })

    {
      home-manager.users.${identity.name} = {
        programs.cava = {
          enable = true;
          settings = {
            general.live-config = 1;
            input.method = if isDarwin then "portaudio" else "pulse";
            input.source = "auto";
            output.method = "noncurses";
            output.channels = "stereo";
            color.theme = "colors";
            smoothing.noise_reduction = 77;
          };
        };
      };
    }
  ]);
}
