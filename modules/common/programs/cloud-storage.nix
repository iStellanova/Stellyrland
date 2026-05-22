{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.cloud-storage.enable = lib.mkEnableOption "Cloud storage clients";

  config = lib.mkIf config.aspects.programs.cloud-storage.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = [
        "google-drive"
      ];
      homebrew.masApps = {
        "OneDrive" = 823766827;
      };
    })

    (lib.optionalAttrs (!isDarwin) {
      home-manager.users.${identity.name} = {
        home.packages = with pkgs; [
          onedrive
          rclone
        ];
      };
    })
  ]);
}
