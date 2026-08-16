{
  flake.modules.darwin.cloud-storage = {
    homebrew.casks = [
      "proton-drive"
      "onedrive"
    ];
  };

  flake.modules.homeManager.cloud-storage = { pkgs, ... }: {
    home.packages = [ pkgs.rclone ];
  };
}
