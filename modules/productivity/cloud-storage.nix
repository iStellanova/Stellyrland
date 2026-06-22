{sn, ...}: {
  sn.productivity = {includes = [sn.cloud-storage];};

  sn.cloud-storage.darwin = _: {
    homebrew.casks = [
      "proton-drive"
    ];
    homebrew.masApps = {
      "OneDrive" = 823766827;
    };
  };

  sn.cloud-storage.homeManager = {pkgs, ...}: {
    home.packages = [pkgs.rclone];
  };
}
