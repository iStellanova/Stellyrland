_:
let
  cliPkgs =
    pkgs: with pkgs; [
      curl
      unzip
      zip
      kitty.terminfo
    ];
  cliOs = { pkgs, ... }: {
    environment.systemPackages = cliPkgs pkgs;
  };
in
{
  flake.modules.nixos.cli = cliOs;
  flake.modules.darwin.cli = cliOs;

  flake.modules.homeManager.cli =
    {
      config,
      host,
      lib,
      ...
    }:
    {
      # Works around an eza bug where theme.yml (vs theme.yaml) is silently
      # ignored when EZA_CONFIG_DIR is unset: https://github.com/eza-community/eza/blob/main/src/options/theme.rs
      home.sessionVariables.EZA_CONFIG_DIR = "${config.home.homeDirectory}/.config/eza";

      programs.fzf.enable = true;
      programs.zoxide.enable = true;
      programs.jq.enable = true;
      programs.ripgrep.enable = true;

      programs.bat.enable = true;

      programs.eza = {
        enable = true;
        enableZshIntegration = true;
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

      programs.zsh.shellAliases = {
        ls = "eza -lh";
        ll = "eza -al";
        lt = "eza -a --tree --level=2";
        ff = "sudo fd -HI -a --exclude .snapshots";
        is = "fzf --preview=\"bat --style=numbers --color=always {}\"";
        cat = "bat";
        grep = "rg";
        man = "tldr";
      }
      // lib.optionalAttrs (host.class != "darwin") {
        # Sets the 'headless' specialisation as the default boot entry and reboots.
        reboot-headless = "sudo /run/current-system/specialisation/headless/bin/switch-to-configuration boot && sudo reboot";
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
        silent = true;
      };
    };
}
