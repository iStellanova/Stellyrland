{ config, lib, pkgs, ... }:

{
  options.aspects.programs.zsh.enable = lib.mkEnableOption "Zsh shell configuration";

  config = lib.mkIf config.aspects.programs.zsh.enable {
    programs.zsh.enable = true;
    environment.systemPackages = [ pkgs.zsh-completions ];

    home-manager.users.stellanova = { pkgs, ... }: {
      home.file.".p10k.zsh".source = ./p10k.zsh;
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "copyfile" "copybuffer" "ssh-agent" ];
        };

        shellAliases = {
          # QOL Aliases
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
            
            # CLI tools integration
            ${lib.optionalString config.aspects.programs.cli.enable ''
              zstyle ':fzf-tab:*' fzf-command fzf
              zstyle ':fzf-tab:*' fzf-preview 'bat --color=always --style=numbers $realpath'
              zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
            ''}

            # Fastfetch startup
            ${lib.optionalString config.aspects.programs.fastfetch.enable ''
              if [[ $(tty) == *"pts"* ]]; then
                fastfetch
              fi
            ''}

            zd() {
              if [ $# -eq 0 ]; then builtin cd ~ && return
              elif [ -d "$1" ]; then builtin cd "$1"
              else z "$@" && printf "\U000F17A9 " && pwd; fi
            }
            open() { xdg-open "$@" >/dev/null 2>&1 &; }

            # Clipboard utilities (Wayland)
            ${lib.optionalString config.aspects.desktop.hyprland.enable ''
              cp2c() { if [[ -z "$1" ]]; then echo "Usage: cp2c <file>" >&2; return 1; fi; wl-copy < "$1"; }
              c2f() { if [[ -z "$1" ]]; then echo "Usage: create-from-clip <filename>" >&2; return 1; fi; wl-paste > "$1"; }
            ''}
          ''
        ];

        plugins = [
          { name = "powerlevel10k"; src = pkgs.zsh-powerlevel10k; file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme"; }
          { name = "zsh-nix-shell"; src = pkgs.zsh-nix-shell; file = "share/zsh-nix-shell/nix-shell.plugin.zsh"; }
          { name = "nix-zsh-completions"; src = pkgs.nix-zsh-completions; file = "share/zsh/plugins/nix-zsh-completions/nix-zsh-completions.plugin.zsh"; }
          { name = "fzf-tab"; src = pkgs.zsh-fzf-tab; file = "share/fzf-tab/fzf-tab.plugin.zsh"; }
          { name = "zsh-history-substring-search"; src = pkgs.zsh-history-substring-search; file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh"; }
        ];
      };
    };
  };
}
