{ sn, ... }: {
  sn.dev = {
    includes = [ sn.zed ];
  };

  sn.zed.darwin = _: {
    homebrew.casks = [ "zed" ];
  };

  sn.zed.homeManager =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = [
        pkgs.nixd
        pkgs.nixfmt
        pkgs.pyright
        pkgs.black
        pkgs.bash-language-server
        pkgs.shfmt
        pkgs.lua-language-server
        pkgs.stylua
        pkgs.ripgrep
        pkgs.fd
        pkgs.mcp-nixos
      ];

      programs.zed-editor = {
        enable = true;
        package = lib.mkIf (host.class == "darwin") null;
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
            "nixd" = {
              "binary" = {
                "path" = "nixd";
              };
              "settings" = import ./_nixd-lsp-config.nix host;
            };
          };
          "assistant" = {
            "version" = 2;
            "dock" = "right";
          };
          "chat_panel" = {
            "dock" = "right";
          };
          "agent_servers" = {
            "claude-acp" = {
              "type" = "registry";
            };
            "gemini" = {
              "default_mode" = "autoEdit";
              "favorite_models" = [ "gemini-3-flash-preview" ];
              "type" = "registry";
            };
            "gemini-cli" = {
              "type" = "registry";
            };
            "mcp-nixos" = {
              "type" = "registry";
            };
          };
        };
      };
    };
}
