{ pkgs, ... }:

{
  users.users.stellanova = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "storage" "disk" "video" "render" "networkmanager" ];
  };

  programs.zsh.enable = true;
}
