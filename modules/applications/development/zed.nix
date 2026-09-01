{
  flake.modules.darwin.zed = {
    homebrew.casks = [ "zed" ];
  };

  flake.modules.nixos.zed =
    { lib, host, ... }:
    {
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/zed"
        ];
      };
    };

  flake.modules.homeManager.zed =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        mcp-nixos
        nixd
        nixfmt
        pyright
        black
        bash-language-server
        clang-tools
        gcc
        shfmt
        lua-language-server
        stylua
        ripgrep
        fd
      ];

      programs.zed-editor = {
        enable = true;
        package = lib.mkIf (host.class == "darwin") null;
        mutableUserSettings = false;
        mutableUserKeymaps = false;
        mutableUserTasks = false;
        extensions = [
          "catppuccin"
          "catppuccin-icons"
          "catppuccin-blur"
          "nix"
        ];
        userSettings = {
          "edit_predictions" = {
            "provider" = "none";
          };
          "format_on_save" = "off";
          "font_family" = "JetBrainsMono Nerd Font Mono";
          "base_keymap" = "JetBrains";
          "session" = {
            "trust_all_worktrees" = true;
          };
          "helix_mode" = true;
          "font_weight" = 300.0;
          "ui_font_weight" = 300.0;
          "ui_font_family" = "JetBrainsMono Nerd Font Propo";
          "line_height" = "comfortable";
          "project_panel" = {
            "dock" = "left";
            "entry_spacing" = "comfortable";
            "hide_gitignore" = true;
            "default_width" = 200.0;
          };
          "outline_panel" = {
            "dock" = "left";
          };
          "collaboration_panel" = {
            "dock" = "left";
          };
          "git_panel" = {
            "dock" = "left";
          };
          "icon_theme" = "Catppuccin Macchiato";
          "telemetry" = {
            "diagnostics" = false;
            "metrics" = false;
          };
          "ui_font_size" = 19.0;
          "font_size" = 18.0;
          "theme" = {
            "mode" = "dark";
            "light" = "Catppuccin Latte";
            "dark" = "Catppuccin Macchiato (Blur)";
          };
          "languages" = {
            "C" = {
              "language_servers" = [ "clangd" ];
            };
            "C++" = {
              "language_servers" = [ "clangd" ];
            };
            "YAML" = {
              "format_on_save" = "off";
            };
            "Nix" = {
              "language_servers" = [ "nixd" ];
              "formatter" = {
                "external" = {
                  "command" = "nixfmt";
                  "arguments" = [ ];
                };
              };
            };
          };
          "minimap" = {
            "show" = "always";
          };
          "lsp" = {
            "clangd" = {
              "binary" = {
                "path" = "${pkgs.clang-tools}/bin/clangd";
                "arguments" = [
                  "--query-driver=${pkgs.gcc}/bin/gcc,${pkgs.gcc}/bin/g++"
                ];
              };
            };
            "nixd" = {
              "binary" = {
                "path" = "nixd";
              };
              "settings" = {
                "nixd" = {
                  "nixpkgs" = {
                    "expr" = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs.outPath { }";
                  };
                  "options" = {
                    "nixos" = {
                      "expr" = "(builtins.getFlake (toString ./.)).nixosConfigurations.stellyrlab.options";
                    };
                  };
                };
              };
            };
          };

          "agent" = {
            "dock" = "right";
          };
          "agent_servers" = {
            "hermes-agent" = {
              "type" = "custom";
              "command" = "hermes";
              "args" = [ "acp" ];
            };
          };
        };
      };
    };
}
