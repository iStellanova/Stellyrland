{ config, lib, identity, ... }:

{
  options.aspects.programs.neovim.enable = lib.mkEnableOption "Neovim editor configuration";

  config = lib.mkIf config.aspects.programs.neovim.enable {
    home-manager.users.${identity.name} = { pkgs, ... }: {
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
        ];
      };

      xdg.configFile."nvim".source = ./nvim;
      # Fuzzyfind files using fzf and bat. Opens the selected file in Neovim.
      programs.zsh.shellAliases = lib.mkIf config.aspects.programs.cli.enable {
        nis = "nvim $(fzf --preview=\"bat --color=always {}\")";
      };
    };
  };
}
