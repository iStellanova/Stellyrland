_: {
  config = {
    # NixOS Cloud Storage Settings
    flake.modules.nixos.default = {
      config,
      lib,
      pkgs,
      identity,
      ...
    }: {
      options.aspects.programs.cloud-storage.enable = lib.mkEnableOption "Cloud storage clients";

      config = lib.mkIf config.aspects.programs.cloud-storage.enable {
        home-manager.users.${identity.name} = {
          home.packages = with pkgs; [
            onedrive
            rclone
          ];
        };
      };
    };

    # Darwin Cloud Storage Settings
    flake.modules.darwin.default = {
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
  };
}
