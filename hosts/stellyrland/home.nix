{ inputs, config, pkgs, ... }:

{
  imports = [
    ../../modules/home/core/default.nix
    ../../modules/home/desktop/default.nix
    ../../modules/home/desktop/hyprland/default.nix
    ../../modules/home/desktop/hyprland/binds.nix
    ../../modules/home/desktop/hyprland/rules.nix
    ../../modules/home/programs/default.nix
    ../../modules/home/programs/zsh.nix
    ../../modules/home/programs/kitty.nix
    ../../modules/home/programs/btop.nix
    ../../modules/home/programs/fastfetch.nix
    ../../modules/home/programs/zed.nix
    ../../modules/home/programs/cava.nix
    ../../modules/home/programs/ns.nix
    ../../modules/home/programs/neovim.nix
    ../../modules/home/programs/vesktop.nix
    ../../modules/home/programs/yazi.nix
    ../../modules/home/programs/noctalia-shell.nix
    ../../modules/home/programs/gsr.nix
    ../../modules/home/programs/antigravity.nix
    ../../modules/home/programs/openrgb/default.nix
    ../../modules/home/core/xdg.nix
  ];
}
