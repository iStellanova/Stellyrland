{ inputs, ... }:
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
    environment.variables.TERMINFO_DIRS = [ "${pkgs.kitty.terminfo}/share/terminfo" ];
  };
  cliNixos =
    {
      lib,
      host,
      ...
    }:
    {
      imports = [
        cliOs
      ]
      ++ lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username} = {
          directories = [
            ".local/share/zoxide"
            ".local/share/direnv"
          ];
          files = [
            {
              file = ".zsh_history";
              how = "symlink";
            }
          ];
        };
      };
    };
in
{
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.cli = cliNixos;
  flake.modules.darwin.cli = cliOs;

  flake.modules.homeManager.cli =
    {
      config,
      lib,
      ...
    }:
    {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      # Works around an eza bug where theme.yml (vs theme.yaml) is silently
      # ignored when EZA_CONFIG_DIR is unset: https://github.com/eza-community/eza/blob/main/src/options/theme.rs
      home.sessionVariables.EZA_CONFIG_DIR = "${config.home.homeDirectory}/.config/eza";

      programs.fzf.enable = true;
      programs.zoxide.enable = true;
      programs.jq.enable = true;
      programs.ripgrep.enable = true;
      programs.bat.enable = true;
      programs.fd.enable = true;
      programs.nix-index.enable = true;
      programs.nix-index-database.comma.enable = true;

      programs.eza = {
        enable = true;
        enableZshIntegration = true;
        icons = "auto";
        extraOptions = [
          "-lh"
          "--group-directories-first"
          "--header"
          "--short-nix"
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
        cat = "bat";
        grep = "rg";
        man = "tldr";
      };

      programs.zsh.initContent = lib.mkAfter ''
        zstyle ':fzf-tab:*' fzf-command fzf
        zstyle ':fzf-tab:*' fzf-preview 'bat --color=always --style=numbers $realpath'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      '';

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };
    };
}
