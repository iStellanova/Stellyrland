{ config, lib, pkgs, identity, ... }:

{
  options.aspects.programs.cli.enable = lib.mkEnableOption "Common CLI utilities" // { default = true; };

  config = lib.mkIf config.aspects.programs.cli.enable {
    environment.systemPackages = with pkgs; [
      curl                     # A command line tool for transferring data with URL syntax
      unzip                    # Extraction utility for archives compressed in .zip format
      zip                      # Archiver for .zip files
      croc                     # Easily and securely send things from one computer to another
    ];

    # Enables special tools.
    home-manager.users.${identity.name} = {
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

      programs.zsh.shellAliases = {
        # QOL aliases
        ls = "eza -lh";
        ll = "eza -al";
        lt = "eza -a --tree --level=2";
        ff = "sudo fd -HI -a --exclude .snapshots";
        is = "fzf --preview=\"bat --style=numbers --color=always {}\"";
        cat = "bat";
        grep = "rg";
        man = "tldr";
      };

      # fd - fast directory search
      programs.fd.enable = true;

      # comma - command line interface for managing dotfiles
      home.packages = with pkgs; [
        comma
      ];

      # direnv - environment variable management
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      # nix-index - index for nix package search
      programs.nix-index.enable = true;
    };
  };
}
