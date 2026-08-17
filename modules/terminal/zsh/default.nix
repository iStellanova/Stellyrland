let
  zshOsPkg = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.zsh-completions ];
  };
in
{
  flake.modules.nixos.zsh = zshOsPkg;
  flake.modules.darwin.zsh = zshOsPkg;

  flake.modules.homeManager.zsh =
    {
      pkgs,
      lib,
      host,
      ...
    }:
    {
      home.file.".p10k.zsh".text = import ./_p10k.nix { inherit lib; };

      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        historySubstringSearch = {
          enable = true;
          searchUpKey = [
            "^[[A"
            "^P"
          ];
          searchDownKey = [
            "^[[B"
            "^N"
          ];
        };

        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "copyfile"
            "copybuffer"
          ];
        };

        initContent = lib.mkMerge [
          (lib.mkBefore ''
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
          '')
          ''
            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

            # Fix for fzf-tab and other completion-related plugins
            zstyle ':completion:*:descriptions' format '[%d]'
            zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

            ${lib.optionalString (host.class != "darwin") ''
              open() { xdg-open "$@" >/dev/null 2>&1 &; }
            ''}
          ''
        ];

        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
          {
            name = "zsh-nix-shell";
            src = pkgs.zsh-nix-shell;
            file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
          }
          {
            name = "nix-zsh-completions";
            src = pkgs.nix-zsh-completions;
            file = "share/zsh/plugins/nix-zsh-completions/nix-zsh-completions.plugin.zsh";
          }
          {
            name = "fzf-tab";
            src = pkgs.zsh-fzf-tab;
            file = "share/fzf-tab/fzf-tab.plugin.zsh";
          }
        ];
      };
    };
}
