{ inputs, ... }:
{
  flake-file.inputs.nvf = {
    url = "github:notashelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Also declared in ai-tools.nix; duplicate declarations of the same input merge fine.
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
          };

          clipboard = {
            enable = true;
            registers = "unnamedplus";
            providers.wl-copy.enable = true;
          };

          visuals.nvim-web-devicons.enable = true;

          filetree.neo-tree.enable = true;

          utility.multicursors.enable = true;

          mini.surround.enable = true;
          mini.ai.enable = true;

          telescope.enable = true;

          binds.whichKey = {
            enable = true;
            register = {
              "<leader>a" = "+Claude";
              "<leader>c" = "+Gemini";
              "<leader>f" = "+Find";
            };
          };

          statusline.lualine.enable = true;
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

            # nixd/nixfmt, not nvf's nil/alejandra defaults, to match Zed and Helix.
            nix = {
              enable = true;
              lsp.servers = [ "nixd" ];
              format.type = [ "nixfmt" ];
            };
            lua.enable = true;
            bash.enable = true;
            markdown.enable = true;
          };

          lsp.servers.nixd.settings = import ./_nixd-lsp-config.nix host;

          # gemini_cli, not claude_code: the claude_code ACP adapter needs a
          # consumer CLAUDE_CODE_OAUTH_TOKEN, which Anthropic's ToS bans outside
          # Claude Code/claude.ai itself. gemini_cli's ACP flag is built for
          # third-party clients and reuses `gemini auth login` directly.
          assistant.codecompanion-nvim = {
            enable = true;
            setupOpts.interactions.chat.adapter = "gemini_cli";
          };

          # claudecode.nvim speaks Claude Code's own IDE-integration protocol
          # (lock file + local WebSocket/MCP) and launches `claude` as a
          # subprocess — no OAuth token reuse. provider = "native" is a plain
          # split, skipping the optional snacks.nvim dependency.
          extraPlugins.claudecode-nvim = {
            package = pkgs.vimPlugins.claudecode-nvim;
            setup = ''
              require("claudecode").setup({
                terminal = {
                  provider = "native",
                },
              })
            '';
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

          luaConfigRC.claude-keymaps = ''
            vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
            vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
            vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add buffer to Claude" })
            vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })
            vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude diff" })
            vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff" })
          '';

          luaConfigRC.codecompanion-keymaps = ''
            vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat toggle<cr>", { desc = "Toggle Gemini chat" })
            vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "Gemini actions" })
          '';

          # Terminal-mode maps exit terminal-insert first so <C-hjkl> also works
          # for leaving Claude's panel.
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

          # nodejs: Claude Code's session hooks shell out to `node`; without it
          # on PATH the IDE-integration handshake never completes.
          extraPackages = [
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
            inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.gemini-cli
            pkgs.nodejs
          ];
        };
      };
    };
}
