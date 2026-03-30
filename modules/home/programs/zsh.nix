{ config, pkgs, ... }:

{
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
      c = "clear";
      pf = "fastfetch";
      ls = "eza -lh --group-directories-first --icons=auto";
      ll = "eza -al --group-directories-first --icons=always";
      lt = "eza -a --tree --level=2 --icons=always";
      cd = "zd";
      ff = "sudo fd -HI -a --exclude .snapshots";
      is = "fzf --preview=\"bat --style=numbers --color=always {}\"";
      nis = "nvim $(fzf --preview=\"bat --color=always {}\")";
      cat = "bat";
      grep = "rg";
      decedit = "vim ~/dotfiles/source.py";
      man = "tldr";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      rebuild = "git -C /etc/nixos add . && nh os switch";
      upgrade = "git -C /etc/nixos add . && nh os switch --update";
      cdn = "cd /etc/nixos/";
    };

    initContent = ''
      # Source your p10k config if it exists
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Fix for fzf-tab and other completion-related plugins
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-preview 'bat --color=always --style=numbers $realpath'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

      if [[ $(tty) == *"pts"* ]]; then
        fastfetch
      fi

      zi() {
        cd "$(zoxide query -i)"
      }

      zd() {
        if [ $# -eq 0 ]; then
          builtin cd ~ && return
        elif [ -d "$1" ]; then
          builtin cd "$1"
        else
          z "$@" && printf "\U000F17A9 " && pwd
        fi
      }

      open() {
        xdg-open "$@" >/dev/null 2>&1 &
      }

      cp2c() {
        if [[ -z "$1" ]]; then
          echo "Usage: cp2c <file>" >&2
          return 1
        fi
        wl-copy < "$1"
      }

      c2f() {
        if [[ -z "$1" ]]; then
          echo "Usage: create-from-clip <filename>" >&2
          return 1
        fi
        wl-paste > "$1"
      }
    '';

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
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];
  };

  programs.zoxide.enable = true;
  programs.fzf.enable = true;
}
