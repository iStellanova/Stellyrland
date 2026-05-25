_: {
  config = {
    # NixOS Media Editing Settings
    flake.modules.nixos.media-editing = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.media-editing.enable = lib.mkEnableOption "Media editing and production tools";

      config = lib.mkIf config.aspects.programs.media-editing.enable {
        environment.systemPackages = with pkgs; [
          davinci-resolve
          gimp
          obs-studio
          parabolic
        ];
      };
    };

    # Darwin Media Editing Settings
    flake.modules.darwin.media-editing = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.media-editing.enable = lib.mkEnableOption "Media editing and production tools";

      config = lib.mkIf config.aspects.programs.media-editing.enable {
        homebrew.casks = [
          "gimp"
          "obs"
        ];
      };
    };

    # Home Manager Media Editing Settings
    flake.modules.homeManager.media-editing = {
      osConfig,
      pkgs,
      lib,
      ...
    }:
      lib.mkIf (osConfig ? aspects.programs.media-editing && osConfig.aspects.programs.media-editing.enable) {
        home.packages = [pkgs.losslesscut-bin];
      };
  };
}
