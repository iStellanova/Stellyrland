_: {
  # NixOS Cloud Storage Settings
  # Darwin Cloud Storage Settings
  flake.modules.darwin.cloud-storage = _: {
    homebrew.casks = [
      "google-drive"
      "microsoft-onedrive"
    ];
  };

  # Home Manager Cloud Storage Settings
  flake.modules.homeManager.cloud-storage = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.rclone] ++ lib.optional pkgs.stdenv.isLinux pkgs.onedrive;
  };
}
