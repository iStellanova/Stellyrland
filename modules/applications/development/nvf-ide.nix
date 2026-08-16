{ inputs, ... }:
{
  flake-file.inputs.nvf = {
    url = "github:notashelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.nvf-ide =
    { pkgs, host, ... }:
    {
      imports = [ inputs.nvf.homeManagerModules.default ];
      programs.nvf = {
        enable = true;
        settings.vim = {
          enableLuaLoader = true;
          theme = {
            enable = true;
            name = "catppuccin";
            style = "macchiato";
            transparent = true;
          };

          # Treesitter folding, unfolded by default.
          options = {
            foldmethod = "expr";
            foldexpr = "v:lua.vim.treesitter.foldexpr()";
            foldlevelstart = 99;
            foldlevel = 99;
            shiftwidth = 2;
            tabstop = 2;
            softtabstop = 2;
            autoread = true;
          };

          clipboard = {
            enable = true;
            registers = "unnamedplus";
            providers.wl-copy.enable = true;
          };

          visuals.nvim-web-devicons.enable = true;
          filetree.neo-tree = {
            enable = true;
            setupOpts.filesystem.use_libuv_file_watcher = true;
            setupOpts.git_status_async = true;
          };

          utility.multicursors.enable = true;
          mini.surround.enable = true;
          mini.ai.enable = true;
          telescope.enable = true;
          binds.whichKey = {
            enable = true;
            register = {
              "<leader>f" = "+Find";
              "<leader>o" = "+OpenCode";
            };
          };

          statusline.lualine = {
            enable = true;
            activeSection.z = [ "require('opencode').statusline" ];
          };
          tabline.nvimBufferline.enable = true;
          git.enable = true;
          git.gitsigns.enable = true;
          comments.comment-nvim.enable = true;
          autopairs.nvim-autopairs.enable = true;
          utility.motion.flash-nvim.enable = true;
          visuals.indent-blankline.enable = true;
          visuals.nvim-scrollbar.enable = true;
          notify.nvim-notify.enable = true;
          ui.illuminate.enable = true;
          ui.colorizer.enable = true;

          # lazygit shells out via its own nix store path, not $PATH — no
          # extraPackages entry needed.
          terminal.toggleterm = {
            enable = true;
            lazygit.enable = true;
          };

          autocomplete.blink-cmp.enable = true;
          formatter.conform-nvim.enable = true;
          lsp = {
            enable = true;
            inlayHints.enable = true;
            formatOnSave = true;
          };

          languages = {
            enableTreesitter = true;
            enableFormat = true;

            # nixd/nixfmt, not NVF's nil/alejandra defaults, to match Zed.
            nix = {
              enable = true;
              lsp.servers = [ "nixd" ];
              format.type = [ "nixfmt" ];
            };

            lua = {
              enable = true;
              extensions.lazydev.enable = true;
            };

            bash.enable = true;
            markdown = {
              enable = true;
              extensions.render-markdown-nvim.enable = true;
            };
          };

          lsp.servers.nixd.settings = {
            nixpkgs.expr = "import (builtins.getFlake \"${host.flakePath}\").inputs.nixpkgs {}";
            options =
              if host.class == "nixos" then
                {
                  nixos.expr = "(builtins.getFlake \"${host.flakePath}\").nixosConfigurations.${host.name}.options";
                }
              else
                {
                  darwin.expr = "(builtins.getFlake \"${host.flakePath}\").darwinConfigurations.${host.name}.options";
                };
          };

          # Connects nvim to the system `opencode --port` server (see
          # opencode/default.nix), sharing context so the auth plugins apply here too.
          extraPlugins.opencode-nvim = {
            package = pkgs.vimPlugins.opencode-nvim;
          };

          luaConfigRC.filetree-keymaps = ''
            vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })

            -- "show" not "focus": opens as a persistent sidebar without stealing focus.
            vim.api.nvim_create_autocmd("VimEnter", {
              once = true,
              callback = function()
                require("neo-tree.command").execute({ action = "show" })
              end,
            })
          '';

          luaConfigRC.opencode = ''
            -- opencode.nvim discovers a running `opencode --port` server, else
            -- starts one via server.start; host it in toggleterm for <leader>ot.
            local opencode_term

            local function get_opencode_term()
              if not opencode_term then
                opencode_term = require("toggleterm.terminal").Terminal:new({
                  cmd = "opencode --port",
                  direction = "vertical",
                })
              end
              return opencode_term
            end

            vim.g.opencode_opts = {
              server = {
                start = function()
                  get_opencode_term():open()
                end,
              },
            }

            vim.keymap.set({ "n", "x" }, "<leader>oa", function()
              require("opencode").ask("@this: ")
            end, { desc = "Ask opencode" })
            vim.keymap.set({ "n", "x" }, "<leader>os", function()
              require("opencode").select()
            end, { desc = "Opencode actions" })
            vim.keymap.set({ "n", "t" }, "<leader>ot", function()
              get_opencode_term():toggle()
            end, { desc = "Toggle opencode" })
          '';

          luaConfigRC.autoread-checktime = ''
            vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
              command = "checktime",
            })
          '';

          # Terminal-mode maps exit terminal-insert first so <C-hjkl> also works
          # for leaving opencode's embedded terminal.
          luaConfigRC.window-nav-keymaps = ''
            vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
            vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
            vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
            vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })

            vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Window left" })
            vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Window right" })
            vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Window down" })
            vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Window up" })
          '';

          # opencode.nvim shells out to `opencode --port`; keep it on PATH inside
          # nvim even though programs.opencode also installs it.
          extraPackages = [
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
          ];
        };
      };
    };
}
