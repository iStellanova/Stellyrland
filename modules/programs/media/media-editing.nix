_: {
  config = {
    # NixOS Media Editing Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.media-editing.enable = lib.mkEnableOption "Media editing and production tools";

      config = lib.mkIf config.aspects.programs.media-editing.enable {
        home-manager.users.${identity.name} = {
          home.packages = with pkgs; [
            losslesscut-bin
          ];
        };

        environment.systemPackages = with pkgs; [
          davinci-resolve
          gimp
          obs-studio
          parabolic
        ];
      };
    };

    # Darwin Media Editing Settings
    flake.modules.darwin.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.media-editing.enable = lib.mkEnableOption "Media editing and production tools";

      config = lib.mkIf config.aspects.programs.media-editing.enable {
        home-manager.users.${identity.name} = {
          home.packages = with pkgs; [
            losslesscut-bin
          ];
        };

        homebrew.casks = [
          "gimp"
          "obs"
        ];
      };
    };
  };
}
