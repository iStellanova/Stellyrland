_: {
  config = {
    # NixOS Cloud Storage Settings
    flake.modules.nixos.cloud-storage = {lib, ...}: {
      options.aspects.programs.cloud-storage.enable = lib.mkEnableOption "Cloud storage clients";
    };

    # Darwin Cloud Storage Settings
    flake.modules.darwin.cloud-storage = {
      config,
      lib,
      ...
    }: {
      options.aspects.programs.cloud-storage.enable = lib.mkEnableOption "Cloud storage clients";

      config = lib.mkIf config.aspects.programs.cloud-storage.enable {
        homebrew.casks = [
          "google-drive"
        ];
        homebrew.masApps = {
          "OneDrive" = 823766827;
        };
      };
    };

    # Home Manager Cloud Storage Settings
    flake.modules.homeManager.cloud-storage = {
      osConfig,
      pkgs,
      lib,
      ...
    }: let
      isDarwin = osConfig ? system.defaults;
    in
      lib.mkIf (osConfig ? aspects.programs.cloud-storage && osConfig.aspects.programs.cloud-storage.enable && !isDarwin) {
        home.packages = with pkgs; [onedrive rclone];
      };
  };
}
