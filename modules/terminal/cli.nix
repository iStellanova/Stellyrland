{ inputs, ... }:
let
  cliPkgs =
    pkgs: with pkgs; [
      curl
      unzip
      zip
      kitty.terminfo
      inputs.pnix.packages.${pkgs.stdenv.hostPlatform.system}.default
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
  pins.nix-index-database = {
    url = "https://github.com/nix-community/nix-index-database";
    follows.nixpkgs = "nixpkgs";
  };

  modules.nixos.cli = cliNixos;
  modules.darwin.cli = cliOs;

  modules.homeManager.cli =
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

      programs = {
        fzf.enable = true;
        zoxide.enable = true;
        jq.enable = true;
        ripgrep.enable = true;
        bat.enable = true;
        fd.enable = true;
        nix-index.enable = true;
        nix-index-database.comma.enable = true;

        eza = {
          enable = true;
          enableZshIntegration = true;
          icons = "auto";
          extraOptions = [
            "-lha"
            "--group-directories-first"
            "--header"
            "--short-nix"
          ];
        };

        tealdeer = {
          enable = true;
          settings = {
            updates = {
              auto_update = true;
            };
          };
        };

        zsh = {
          shellAliases = {
            cat = "bat";
            grep = "rg";
            man = "tldr";
          };

          initContent = lib.mkAfter ''
            zstyle ':fzf-tab:*' fzf-command fzf
            zstyle ':fzf-tab:*' fzf-preview 'bat --color=always --style=numbers $realpath'
            zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
          '';
        };
      };
    };
}
