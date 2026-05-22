{nixosIdentity, ...}: {
  config = {
    # NixOS Cloud Storage Settings
    flake.modules.nixos.cloud-storage = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.cloud-storage.enable = lib.mkEnableOption "Cloud storage clients";

      config = lib.mkIf config.aspects.programs.cloud-storage.enable {
        home-manager.users.${nixosIdentity.name} = {
          home.packages = with pkgs; [
            onedrive
            rclone
          ];
        };
      };
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
  };
}
