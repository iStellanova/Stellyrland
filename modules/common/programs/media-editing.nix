{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.media-editing.enable = lib.mkEnableOption "Media editing and production tools";

  config = lib.mkIf config.aspects.programs.media-editing.enable (lib.mkMerge [
    {
      home-manager.users.${identity.name} = {
        home.packages = with pkgs; [
          losslesscut-bin
        ];
      };
    }

    (lib.optionalAttrs isDarwin {
      homebrew.casks = [
        "davinci-resolve"
        "obs"
      ];
    })

    (lib.optionalAttrs (!isDarwin) {
      environment.systemPackages = with pkgs; [
        davinci-resolve
        obs-studio
        parabolic
      ];
    })
  ]);
}
