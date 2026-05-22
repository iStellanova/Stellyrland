{
  nixosIdentity,
  darwinIdentity,
  ...
}: {
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
        home-manager.users.${nixosIdentity.name} = {
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
    flake.modules.darwin.media-editing = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.media-editing.enable = lib.mkEnableOption "Media editing and production tools";

      config = lib.mkIf config.aspects.programs.media-editing.enable {
        home-manager.users.${darwinIdentity.name} = {
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
