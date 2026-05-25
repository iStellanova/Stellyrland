{inputs, ...}: {
  flake.modules.homeManager.nixvim = {pkgs, ...}: {
    imports = [inputs.nixvim.homeModules.nixvim];

    config = {
      programs.nixvim = {
        enable = true;
        nixpkgs.source = inputs.nixpkgs;
        defaultEditor = true;

        viAlias = true;
        vimAlias = true;

        luaLoader.enable = true;

        # Theming
        colorschemes.catppuccin = {
          enable = true;
          settings = {
            flavour = "macchiato";
            transparent_background = true;
            integrations = {
              cmp = true;
              gitsigns = true;
              nvimtree = true;
              treesitter = true;
              notify = true;
              mini = {
                enabled = true;
                indentscope_color = "";
              };
            };
          };
        };

        # Options
        opts = {
          number = true;
          relativenumber = true;
          shiftwidth = 2;
          tabstop = 2;
          expandtab = true;
          smartindent = true;
          wrap = false;
          swapfile = false;
          backup = false;
          undofile = true;
          hlsearch = false;
          incsearch = true;
          termguicolors = true;
          scrolloff = 8;
          signcolumn = "yes";
          updatetime = 50;
        };

        # Keymaps
        globals.mapleader = " ";
        keymaps = [
          {
            mode = "n";
            key = "<leader>e";
            action = ":Neotree toggle<CR>";
            options.silent = true;
          }
        ];

        # Plugins
        plugins = {
          lualine.enable = true;
          bufferline.enable = true;
          treesitter.enable = true;
          telescope.enable = true;
          which-key.enable = true;
          gitsigns.enable = true;
          noice.enable = true;
          notify.enable = true;
          web-devicons.enable = true;

          neo-tree = {
            enable = true;
            settings = {
              close_if_last_window = true;
            };
          };

          indent-blankline.enable = true;

          mini = {
            enable = true;
            modules = {
              ai = {};
              bufremove = {};
              comment = {};
              indentscope = {};
              pairs = {};
              surround = {};
            };
          };

          # LSP
          lsp = {
            enable = true;
            servers = {
              nil_ls.enable = true;
              lua_ls.enable = true;
              pyright.enable = true;
              bashls.enable = true;
            };
          };

          # Completion
          cmp = {
            enable = true;
            settings = {
              autoEnableSources = true;
              sources = [
                {name = "nvim_lsp";}
                {name = "path";}
                {name = "buffer";}
              ];
              mapping = {
                "<CR>" = "cmp.mapping.confirm({ select = true })";
                "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              };
            };
          };

          # Formatting
          conform-nvim = {
            enable = true;
            settings = {
              formatters_by_ft = {
                nix = ["alejandra"];
                lua = ["stylua"];
                python = ["black"];
                sh = ["shfmt"];
              };
              formatters = {
                alejandra = {
                  command = "${pkgs.alejandra}/bin/alejandra";
                };
                stylua = {
                  command = "${pkgs.stylua}/bin/stylua";
                };
                shfmt = {
                  command = "${pkgs.shfmt}/bin/shfmt";
                };
                black = {
                  command = "${pkgs.black}/bin/black";
                };
              };
              format_on_save = {
                lsp_fallback = true;
                timeout_ms = 500;
              };
            };
          };
        };

        extraPackages = with pkgs; [
          ripgrep
          fd
        ];
      };
    };
  };

  # NixOS Options Declaration
  flake.modules.nixos.nixvim = _: {
  };

  # Darwin Options Declaration
  flake.modules.darwin.nixvim = _: {
  };
}
