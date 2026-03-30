{ config, pkgs, ... }:

{
  users.users.stellanova = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" "storage" "disk" "video" "render" ];
    packages = with pkgs; [
    ];
  };

  programs.zsh.enable = true;
}
