{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/core/default.nix
    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/services/default.nix
    ../../modules/nixos/gaming.nix
  ];

  networking.hostName = "stellyrland";

  fileSystems."/home/stellanova/ExtraDisk" = {
    device = "/dev/disk/by-uuid/5082e55b-50fd-4f53-a753-157fa30415cc";
    fsType = "ext4";
    options = [ "nofail" "x-gvfs-show" "x-gvfs-name=Extra Disk" ];
  };
}
