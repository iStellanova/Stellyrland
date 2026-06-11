{sn, ...}: {
  sn.dev = {includes = [sn.helix];};

  sn.helix.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    programs.helix = {
      enable = true;
      defaultEditor = true;

      themes.catppuccin_macchiato_transparent = {
        inherits = "catppuccin_macchiato";
        "ui.background" = {};
      };

      settings = {
        theme = lib.mkForce "catppuccin_macchiato_transparent";

        editor = {
          line-number = "relative";
          mouse = true;
          cursorline = true;
          scrolloff = 8;
          color-modes = true;
          idle-timeout = 50;
          true-color = true;

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          indent-guides = {
            render = true;
            character = "╎";
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
            hidden = false;
            git-ignore = true;
          };
        };

        keys.normal = {
          "C-s" = ":w";
          "C-q" = ":q";
          "C-h" = ":bp";
          "C-l" = ":bn";
          "C-w" = ":bc";
        };
      };

      languages = {
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter = {command = "alejandra";};
            language-servers = ["nil"];
          }
          {
            name = "python";
            auto-format = true;
            formatter = {command = "black";};
            language-servers = ["pyright"];
          }
          {
            name = "bash";
            auto-format = true;
            formatter = {command = "shfmt";};
            language-servers = ["bash-language-server"];
          }
          {
            name = "lua";
            auto-format = true;
            formatter = {command = "stylua";};
            language-servers = ["lua-language-server"];
          }
        ];
      };

      extraPackages = with pkgs; [
        nil
        pyright
        bash-language-server
        lua-language-server
        alejandra
        black
        shfmt
        stylua
        ripgrep
        fd
      ];
    };
  };
}
