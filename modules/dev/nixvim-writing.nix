# nixvim recommends against following our nixpkgs — it's tested against its own pinned rev.
{ inputs, ... }:
{
  flake-file.inputs.nixvim.url = "github:nix-community/nixvim";

  flake.modules.homeManager.nixvim-writing =
    { pkgs, ... }:
    {
      imports = [ inputs.nixvim.homeModules.nixvim ];

      programs.nixvim = {
        enable = true;

        # Matches desktop/catppuccin.nix's flavor; transparent_background is catppuccin.nvim's
        # own flag, same idea as helix.nix's catppuccin_macchiato_transparent theme.
        colorschemes.catppuccin = {
          enable = true;
          settings = {
            flavour = "macchiato";
            transparent_background = true;
          };
        };

        opts = {
          wrap = true;
          linebreak = true;
          textwidth = 0;
          undofile = true;
          statusline = "%f %y%=%{wordcount().words} words  %l:%c";
        };

        plugins.zen-mode.enable = true;
        plugins.twilight.enable = true;
        plugins.oil.enable = true;

        plugins.telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fg" = "live_grep";
          };
        };

        extraPlugins = with pkgs.vimPlugins; [
          vim-pandoc
          vim-pandoc-syntax
        ];

        # telescope's find_files/live_grep shell out to these — not auto-added by the
        # nixvim telescope wrapper, and this module should work even if zed.nix (which
        # also happens to install them) isn't imported alongside it.
        extraPackages = with pkgs; [
          ripgrep
          fd
        ];

        extraConfigLua = ''
          -- Autosave on focus/buffer switch — plain vim has no continuous autosave, this
          -- is the native autocmd equivalent instead of pulling in an autosave plugin.
          vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
            command = "silent! wall",
          })

          -- Chapter picker (<leader>fc): find_files scoped to *.md, previewing the flat
          -- title/pov/summary/status frontmatter instead of raw file contents. Frontmatter
          -- is plain `key: value` lines between two `---` markers, all optional — no real
          -- YAML parsing needed for a schema this small.
          local function parse_frontmatter(path)
            local lines = vim.fn.readfile(path, "", 20)
            local meta = {}
            if lines[1] == "---" then
              for i = 2, #lines do
                if lines[i] == "---" then
                  break
                end
                local key, value = lines[i]:match("^(%a+):%s*(.*)$")
                if key then
                  meta[key] = value
                end
              end
            end
            return meta
          end

          local function find_chapters()
            local previewer = require("telescope.previewers").new_buffer_previewer({
              title = "Chapter Summary",
              define_preview = function(self, entry)
                local meta = parse_frontmatter(entry.path)
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
                  "Title:   " .. (meta.title or "—"),
                  "POV:     " .. (meta.pov or "—"),
                  "Status:  " .. (meta.status or "—"),
                  "",
                  "Summary:",
                  meta.summary or "—",
                })
                vim.bo[self.state.bufnr].wrap = true
              end,
            })
            require("telescope.builtin").find_files({
              prompt_title = "Chapters",
              find_command = { "rg", "--files", "-g", "*.md" },
              previewer = previewer,
            })
          end

          vim.keymap.set("n", "<leader>fc", find_chapters, { desc = "Find chapters (frontmatter preview)" })
        '';
      };
    };
}
