{sn, ...}: {
  sn.productivity = {includes = [sn.cloud-storage];};

  sn.cloud-storage.darwin = _: {
    homebrew.casks = [
      "google-drive"
    ];
    homebrew.masApps = {
      "OneDrive" = 823766827;
    };
  };

  sn.cloud-storage.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.rclone] ++ lib.optional pkgs.stdenv.isLinux pkgs.onedrive;
  };
}
