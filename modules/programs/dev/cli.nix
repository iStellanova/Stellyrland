{lib, ...}: {
  config = {
    # NixOS CLI Settings
    flake.modules.nixos.cli = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.cli.enable = lib.mkEnableOption "Common CLI utilities";

      config = lib.mkIf config.aspects.programs.cli.enable {
        environment.systemPackages = with pkgs; [
          curl
          unzip
          zip
          croc
          kitty.terminfo
          efibootmgr
        ];
      };
    };

    # Darwin CLI Settings
    flake.modules.darwin.cli = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.aspects.programs.cli.enable = lib.mkEnableOption "Common CLI utilities";

      config = lib.mkIf config.aspects.programs.cli.enable {
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
      osConfig,
      pkgs,
      ...
    }: let
      isDarwin = osConfig ? system.defaults;
    in
      lib.mkIf (osConfig ? aspects.programs.cli && osConfig.aspects.programs.cli.enable) {
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
          // lib.optionalAttrs (!isDarwin) {
            # Environment switching aliases (Linux only)
            # Sets the 'headless' specialisation as the default boot entry and reboots.
            reboot-headless = "sudo /run/current-system/specialisation/headless/bin/switch-to-configuration boot && sudo reboot";
            # Restores the main system (GUI) as the default boot entry and reboots.
            reboot-gui = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot && sudo reboot";
          };

        # fd - fast directory search
        programs.fd.enable = true;

        # comma - command line interface for managing dotfiles
        home.packages = with pkgs;
          lib.optionals (osConfig ? aspects.programs.nix-index && !osConfig.aspects.programs.nix-index.enable) [
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
