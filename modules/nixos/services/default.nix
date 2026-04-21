{
  imports = [
    ./lact.nix
    ./openrgb.nix
    ./snapper.nix
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.gnome.tinysparql.enable = true;
  services.gnome.localsearch.enable = true;
  services.flatpak.enable = true;

  programs.coolercontrol.enable = true;
  programs.seahorse.enable = true;
  programs.gpu-screen-recorder.enable = true;
}
