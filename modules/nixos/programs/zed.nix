{ config, lib, pkgs, identity, ... }:
{
  options.aspects.programs.zed.enable = lib.mkEnableOption "Zed editor";
  config = lib.mkIf config.aspects.programs.zed.enable {
    home-manager.users.${identity.name} = {
      home.packages = [
        pkgs.nil
        pkgs.nixfmt
      ];

      programs.zed-editor = {
        enable = true;
        userSettings = {
          "agent_servers" = {
            "gemini" = {
              "default_mode" = "autoEdit";
              "favorite_models" = [
                "gemini-3-flash-preview"
              ];
              "type" = "registry";
            };
          };
          "edit_predictions" = {
            "provider" = "copilot";
          };
          "format_on_save" = "off";
          "buffer_font_family" = "JetBrainsMono Nerd Font Mono";
          "base_keymap" = "JetBrains";
          "session" = {
            "trust_all_worktrees" = true;
          };
          "vim_mode" = false;
          "buffer_font_weight" = 300.0;
          "ui_font_weight" = 300.0;
          "ui_font_family" = "JetBrainsMono Nerd Font Propo";
          "buffer_line_height" = "comfortable";
          "project_panel" = {
            "entry_spacing" = "comfortable";
            "hide_gitignore" = true;
            "default_width" = 200.0;
          };
          "icon_theme" = "Catppuccin Macchiato";
          "telemetry" = {
            "diagnostics" = false;
            "metrics" = false;
          };
          "ui_font_size" = 19.0;
          "buffer_font_size" = 18.0;
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
  };
}
