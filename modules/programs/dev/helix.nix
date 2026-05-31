_: {
  # Home Manager Helix Settings
  # Helix is a modern modal text editor written in Rust. It's configured via programs.helix.
  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix = {
      enable = true;
      # defaultEditor = true; # Uncomment this line when you want to make Helix your default editor!

      settings = {
        theme = "catppuccin_macchiato";

        editor = {
          line-number = "relative";
          mouse = true;
          cursorline = true;
          scrolloff = 8;
          color-modes = true; # Show mode color in the statusline
          idle-timeout = 50; # Quick auto-complete and signature popups
          true-color = true;

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          indent-guides = {
            render = true;
            character = "╎"; # Elegant vertical indent guides
            skip-levels = 1;
          };

          lsp = {
            display-messages = true;
            display-inlay-hints = true;
          };

          statusline = {
            left = ["mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator"];
            center = [];
            right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };

          file-picker = {
            hidden = false; # Show hidden files (like dotfiles) in the picker
            git-ignore = true;
          };
        };

        # Custom high-utility keybindings
        keys.normal = {
          # Quick saving and quitting
          "C-s" = ":w";
          "C-q" = ":q";

          # Elegant buffer/tab navigation
          "C-h" = ":bp"; # Previous buffer (back)
          "C-l" = ":bn"; # Next buffer (forward)
          "C-w" = ":bc"; # Close buffer (close tab)
        };
      };

      # Language-specific LSP and auto-formatting configuration
      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {
              command = "alejandra";
            };
            language-servers = ["nil"];
          }
          {
            name = "python";
            auto-format = true;
            formatter = {
              command = "black";
            };
            language-servers = ["pyright"];
          }
          {
            name = "bash";
            auto-format = true;
            formatter = {
              command = "shfmt";
            };
            language-servers = ["bash-language-server"];
          }
          {
            name = "lua";
            auto-format = true;
            formatter = {
              command = "stylua";
            };
            language-servers = ["lua-language-server"];
          }
        ];
      };

      # Self-contained packages only exposed to Helix's PATH
      extraPackages = with pkgs; [
        # Language servers
        nil
        pyright
        bash-language-server
        lua-language-server

        # Formatters
        alejandra
        black
        shfmt
        stylua

        # Search & discovery utilities for the Helix picker
        ripgrep
        fd
      ];
    };
  };
}
