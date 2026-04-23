{ config, lib, ... }:

{
  options.aspects.programs.neovim.enable = lib.mkEnableOption "Neovim editor configuration";

  config = lib.mkIf config.aspects.programs.neovim.enable {
    home-manager.users.stellanova = { pkgs, ... }: {
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

      xdg.configFile."nvim".source = ./nvim;
    };
  };
}
