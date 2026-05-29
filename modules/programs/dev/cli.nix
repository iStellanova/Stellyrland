_: {
  # NixOS CLI Settings
  flake.modules.nixos.cli = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        curl
        unzip
        zip
        croc
        kitty.terminfo
      ];
    };
  };

  # Darwin CLI Settings
  flake.modules.darwin.cli = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        curl
        unzip
        zip
        croc
        kitty.terminfo
      ];
    };
  };

  # Home Manager CLI Settings
  flake.modules.homeManager.cli = {
    pkgs,
    lib,
    ...
  }: {
    programs.fzf.enable = true;
    programs.zoxide.enable = true;
    programs.jq.enable = true;
    programs.ripgrep.enable = true;

    # bat - cat with syntax highlighting
    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };

    # eza - modern replacement for ls
    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    # tealdeer - fast, minimalistic man page viewer
    programs.tealdeer = {
      enable = true;
      settings = {
        updates = {
          auto_update = true;
        };
      };
    };

    programs.zsh.shellAliases =
      {
        # QOL aliases
        ls = "eza -lh";
        ll = "eza -al";
        lt = "eza -a --tree --level=2";
        ff = "sudo fd -HI -a --exclude .snapshots";
        is = "fzf --preview=\"bat --style=numbers --color=always {}\"";
        cat = "bat";
        grep = "rg";
        man = "tldr";
      }
      // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
        # Environment switching aliases (Linux only)
        # Sets the 'headless' specialisation as the default boot entry and reboots.
        reboot-headless = "sudo /run/current-system/specialisation/headless/bin/switch-to-configuration boot && sudo reboot";
        # Restores the main system (GUI) as the default boot entry and reboots.
        reboot-gui = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot && sudo reboot";
      };

    # fd - fast directory search
    programs.zsh.initContent = lib.mkAfter ''
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-preview 'bat --color=always --style=numbers $realpath'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    '';

    programs.fd.enable = true;

    # direnv - environment variable management
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
