{ inputs, pkgs, ... }:

{
  imports = [
    ./antigravity.nix
    ./btop.nix
    ./cava.nix
    ./fastfetch.nix
    ./gsr.nix
    ./kitty.nix
    ./neovim.nix
    ./noctalia-shell.nix
    ./ns.nix
    ./vesktop.nix
    ./yazi.nix
    ./zed.nix
    ./zsh.nix
    ./openrgb
    ./quickshell.nix
  ];

  home.packages = with pkgs; [
    # --- Browsers ---
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default # Zen Browser - A fork of Firefox focused on privacy and customization

    # --- CLI Utilities ---
    comma                    # Run software without installing it

    # --- Wayland Utilities ---
    cliphist                 # Wayland clipboard manager
    wl-clipboard             # Command-line copy/paste utilities for Wayland
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nix-index.enable = true;
}
