{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/core/default.nix
    ../../modules/nixos/core/users.nix
    ../../modules/nixos/core/packages.nix
    ../../modules/nixos/desktop/hyprland.nix
    ../../modules/nixos/services/default.nix
    ../../modules/nixos/services/lact.nix
    ../../modules/nixos/services/openrgb.nix
    ../../modules/nixos/services/snapper.nix
  ];

  networking.hostName = "stellyrland";

  fileSystems."/home/stellanova/ExtraDisk" = {
    device = "/dev/disk/by-uuid/5082e55b-50fd-4f53-a753-157fa30415cc";
    fsType = "ext4";
    options = [ "nofail" "x-gvfs-show" "x-gvfs-name=Extra Disk" ];
  };

  services.udev.extraRules = ''
    # Force extra-disk to be treated as a removable/external device for udisks2
    ENV{ID_FS_UUID}=="5082e55b-50fd-4f53-a753-157fa30415cc", ENV{UDISKS_AUTO}="1", ENV{UDISKS_IGNORE}="0"
  '';

  # Systemd Patch (Keep commented as in original)
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     systemd = prev.systemd.overrideAttrs (old: {
  #       patches = (old.patches or []) ++ [
  #         ./patches/remove-birthdate.patch
  #       ];
  #     });
  #   })
  # ];

  # systemd.services.systemd-userdbd.enable = false;
  # systemd.sockets.systemd-userdbd.enable = false;
}
