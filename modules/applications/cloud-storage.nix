_: {
  flake.modules.darwin.cloud-storage = _: {
    homebrew.casks = [
      "proton-drive"
      "onedrive"
    ];
  };

  flake.modules.homeManager.cloud-storage = { pkgs, ... }: {
    home.packages = [ pkgs.rclone ];
  };
}
