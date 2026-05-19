{
  config,
  lib,
  pkgs,
  identity,
  isDarwin,
  ...
}: {
  options.aspects.programs.zsh.enable = lib.mkEnableOption "Zsh shell configuration";

  config = lib.mkIf config.aspects.programs.zsh.enable {
    # Enables zsh.
    programs.zsh.enable = true;
    environment.systemPackages = [pkgs.zsh-completions];

    home-manager.users.${identity.name} = {pkgs, ...}: {
      programs.starship = {
        enable = true;
        enableZshIntegration = false; # We will handle this manually to ensure order
        settings = {
          # ... rest of settings unchanged ...
          add_newline = true;

          format = lib.concatStrings [
            "[](#a3aed2)"
            "$os"
            "[](bg:#769ff0 fg:#a3aed2)"
            "$directory"
            "[](fg:#769ff0 bg:#394260)"
            "$git_branch"
            "$git_status"
            "[](fg:#394260 bg:#212736)"
            "$nodejs"
            "$rust"
            "$golang"
            "[](fg:#212736 bg:#1d2230)"
            "$time"
            "[ ](fg:#1d2230)"
            "\n$character"
          ];

          os = {
            disabled = false;
            style = "bg:#a3aed2 fg:#000000";
            symbols = {
              NixOS = " ";
              Macos = "󰀵 ";
            };
            format = "[$symbol]($style)";
          };

          directory = {
            style = "fg:#e3e5e5 bg:#769ff0";
            format = "[ $path ]($style)";
            truncation_length = 3;
            truncation_symbol = "…/";
          };

          git_branch = {
            symbol = "";
            style = "bg:#394260";
            format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
          };

          git_status = {
            style = "bg:#394260";
            format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
          };

          nodejs = {
            symbol = "";
            style = "bg:#212736";
            format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
          };

          rust = {
            symbol = "";
            style = "bg:#212736";
            format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
          };

          golang = {
            symbol = "";
            style = "bg:#212736";
            format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
          };

          time = {
            disabled = false;
            time_format = "%R";
            style = "bg:#1d2230";
            format = "[[  $time ](fg:#a0a9cb bg:#1d2230)]($style)";
          };

          character = {
            success_symbol = "[❯](bold green)";
            error_symbol = "[❯](bold red)";
          };

        };
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        # Oh My Zsh and plugins.
        oh-my-zsh = {
          enable = true;
          plugins = ["git" "copyfile" "copybuffer"];
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
          ''
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

            # zd - Smart 'cd'. Falls back to 'z' (zoxide) for rapid jumping if the directory
            # isn't a direct child of the current path.
            zd() {
              if [ $# -eq 0 ]; then builtin cd ~ && return
              elif [ -d "$1" ]; then builtin cd "$1"
              else z "$@" && printf "\U000F17A9 " && pwd; fi
            }
            ${lib.optionalString (!isDarwin) ''
              open() { xdg-open "$@" >/dev/null 2>&1 &; }
            ''}

            # Clipboard utilities for Wayland/Hyprland
            # cp2c: Copy file content to clipboard
            # c2f: Create file from clipboard content
            ${lib.optionalString (!isDarwin && (config.aspects.desktop.hyprland.enable or false)) ''
              cp2c() { if [[ -z "$1" ]]; then echo "Usage: cp2c <file>" >&2; return 1; fi; wl-copy < "$1"; }
              c2f() { if [[ -z "$1" ]]; then echo "Usage: create-from-clip <filename>" >&2; return 1; fi; wl-paste > "$1"; }
            ''}
          ''
          (lib.mkAfter ''
            # Initialize Starship
            eval "$(${pkgs.starship}/bin/starship init zsh)"

            # Transient prompt: collapse to ❯ on Enter, then restore the promptsubst
            # string so starship's precmd env vars are picked up by the next render.
            _transient_accept_line() {
              if [[ -z "$PREBUFFER" ]]; then
                local _sp="$PROMPT" _srp="$RPROMPT"
                PROMPT='%F{green}❯%f '
                RPROMPT=""
                zle reset-prompt
                PROMPT="$_sp"
                RPROMPT="$_srp"
              fi
              zle .accept-line
            }
            zle -N accept-line _transient_accept_line
          '')
        ];

        plugins = [
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
    };
  };
}
