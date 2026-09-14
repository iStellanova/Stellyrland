{
  modules.darwin.cloud-storage = {
    homebrew.casks = [
      "proton-drive"
      "onedrive"
    ];
  };

  modules.homeManager.cloud-storage = { pkgs, ... }: {
    home.packages = [ pkgs.rclone ];
  };
}
