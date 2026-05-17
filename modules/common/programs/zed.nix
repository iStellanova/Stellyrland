{ config, lib, pkgs, identity, isDarwin, ... }:
{
  options.aspects.programs.zed.enable = lib.mkEnableOption "Zed editor";
  config = lib.mkIf config.aspects.programs.zed.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = [ "zed" ];
    })

    {
      home-manager.users.${identity.name} = {
        home.packages = lib.optionals (!isDarwin) [
          pkgs.nil
          pkgs.nixfmt
        ];

        programs.zed-editor = {
          enable = true;
          package = if isDarwin then null else pkgs.zed-editor;
          mutableUserSettings = false;
          mutableUserKeymaps = false;
          mutableUserTasks = false;
          userSettings = {
            "inline_completions" = {
              "provider" = "none";
            };
            "features" = {
              "copilot" = false;
            };
            "format_on_save" = "off";
            "font_family" = "JetBrainsMono Nerd Font Mono";
            "base_keymap" = "JetBrains";
            "session" = {
              "trust_all_worktrees" = true;
            };
            "vim_mode" = false;
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
              "YAML" = {
                "format_on_save" = "off";
              };
              "Nix" = {
                "language_servers" = [ "nil" ];
                "formatter" = {
                  "external" = {
                    "command" = "nixfmt";
                    "arguments" = [ ];
                  };
                };
              };
            };
            "lsp" = {
              "nil" = {
                "binary" = {
                  "path" = "nil";
                };
              };
            };
          };
        };

        home.sessionVariables = {
          EDITOR = "zed --wait";
          VISUAL = "zed --wait";
        };
      };
    }
  ]);
}
