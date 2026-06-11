{sn, ...}: let
  cliPkgs = pkgs: with pkgs; [curl unzip zip croc kitty.terminfo];
in {
  sn.terminal = {includes = [sn.cli];};

  sn.cli.nixos = {pkgs, ...}: {
    environment.systemPackages = cliPkgs pkgs;
  };

  sn.cli.darwin = {pkgs, ...}: {
    environment.systemPackages = cliPkgs pkgs;
  };

  sn.cli.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    programs.fzf.enable = true;
    programs.zoxide.enable = true;
    programs.jq.enable = true;
    programs.ripgrep.enable = true;

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };

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
        # Sets the 'headless' specialisation as the default boot entry and reboots.
        reboot-headless = "sudo /run/current-system/specialisation/headless/bin/switch-to-configuration boot && sudo reboot";
        # Restores the main system (GUI) as the default boot entry and reboots.
        reboot-gui = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot && sudo reboot";
      };

    programs.zsh.initContent = lib.mkAfter ''
      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' fzf-preview 'bat --color=always --style=numbers $realpath'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    '';

    programs.fd.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
