{ pkgs, ... }:

{
  users.users.stellanova = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "storage" "disk" "video" "render" "networkmanager" "seat" ];
  };

  programs.zsh.enable = true;
}
