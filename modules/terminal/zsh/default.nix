{ sn, ... }:
let
  zshOsPkg = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.zsh-completions ];
  };
in
{
  sn.terminal = {
    includes = [ sn.zsh ];
  };

  sn.zsh.os = zshOsPkg;

  sn.zsh.homeManager =
    {
      pkgs,
      lib,
      host,
      ...
    }:
    {
      home.file.".p10k.zsh".text = import ./_p10k.nix { inherit lib; };

      programs.zsh = {
        enableCompletion = true;
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

        shellAliases = {
          c = "clear";
          cd = "zd";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
        };

        initContent = lib.mkMerge [
          (lib.mkBefore ''
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
          '')
          ''
            # Source your p10k config if it exists
            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

            # Fix for fzf-tab and other completion-related plugins
            zstyle ':completion:*:descriptions' format '[%d]'
            zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

            # zd - Smart 'cd'. Falls back to 'z' (zoxide) for rapid jumping if the directory
            # isn't a direct child of the current path.
            zd() {
              if [ $# -eq 0 ]; then builtin cd ~ && return
              elif [ -d "$1" ]; then builtin cd "$1"
              else z "$@" && printf "\U000F17A9 " && pwd; fi
            }
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
