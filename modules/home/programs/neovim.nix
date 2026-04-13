{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
    extraPackages = with pkgs; [
      lua-language-server
      stylua
      nil
      shellcheck
      gcc
      unzip
    ];
  };

  # Symlink the nvim configuration from the nix store
  xdg.configFile."nvim".source = ./nvim;
}
