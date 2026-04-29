{ config, lib, pkgs, identity, ... }:

{
  options.aspects.programs.cli.enable = lib.mkEnableOption "Common CLI utilities" // { default = true; };

  config = lib.mkIf config.aspects.programs.cli.enable {
    environment.systemPackages = with pkgs; [
      curl                     # A command line tool for transferring data with URL syntax
      unzip                    # Extraction utility for archives compressed in .zip format
      zip                      # Archiver for .zip files
    ];
    
    home-manager.users.${identity.name} = {
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

      programs.zsh.shellAliases = {
        # QOL aliases
        ls = "eza -lh"; # Minimal manual override for preference
        ll = "eza -al";
        lt = "eza -a --tree --level=2";
        ff = "sudo fd -HI -a --exclude .snapshots";
        is = "fzf --preview=\"bat --style=numbers --color=always {}\"";
        cat = "bat";
        grep = "rg";
        man = "tldr";
      };

      programs.fd.enable = true;

      home.packages = with pkgs; [ 
        comma
      ];

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      programs.nix-index.enable = true;
    };
  };
}
