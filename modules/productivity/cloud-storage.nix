{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.cloud-storage ];
  };

  sn.cloud-storage.darwin = _: {
    homebrew.casks = [
      "proton-drive"
      "onedrive"
    ];
  };

  sn.cloud-storage.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.rclone ];
  };
}
