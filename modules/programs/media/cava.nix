{
  lib,
  ...
}: {
  config = {
    # NixOS Options Declaration
    flake.modules.nixos.default = {
      lib,
      ...
    }: {
      options.aspects.programs.cava.enable = lib.mkEnableOption "Cava";
    };

    # Darwin Cava Settings
    flake.modules.darwin.default = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.cava.enable = lib.mkEnableOption "Cava";

      config = lib.mkIf config.aspects.programs.cava.enable {
        homebrew.brews = ["cava"];
      };
    };

    # Home Manager Cava Settings
    flake.modules.homeManager.default = {
      osConfig,
      ...
    }: let
      isDarwin = osConfig ? system.defaults;
    in
      lib.mkIf (osConfig ? aspects.programs.cava && osConfig.aspects.programs.cava.enable) {
        programs.cava = {
          enable = true;
          settings = {
            general.live-config = 1;
            input.method =
              if isDarwin
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
  };
}
