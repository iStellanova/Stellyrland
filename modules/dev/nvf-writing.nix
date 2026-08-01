{ inputs, ... }:
{
  flake-file.inputs.nvf = {
    url = "github:notashelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.nvf-writing =
    { pkgs, ... }:
    {
      imports = [ inputs.nvf.homeManagerModules.default ];

      programs.nvf = {
        enable = true;

        settings.vim = {
          # Matches desktop/catppuccin.nix's flavor and helix.nix's
          # catppuccin_macchiato_transparent theme.
          theme = {
            enable = true;
            name = "catppuccin";
            style = "macchiato";
            transparent = true;
          };

          options = {
            wrap = true;
            linebreak = true;
            textwidth = 0;
            undofile = true;
            statusline = "%f %y%=%{wordcount().words} words  %l:%c";
          };

          utility.oil-nvim.enable = true;

          # Defaults already land on <leader>ff / <leader>fg.
          telescope.enable = true;

          # zen-mode.nvim and twilight.nvim have no first-class nvf module,
          # so they're wired by hand. vim-pandoc(-syntax) need no setup call.
          extraPlugins = with pkgs.vimPlugins; {
            zen-mode = {
              package = zen-mode-nvim;
              setup = "require('zen-mode').setup {}";
            };
            twilight = {
              package = twilight-nvim;
              setup = "require('twilight').setup {}";
            };
            vim-pandoc.package = vim-pandoc;
            vim-pandoc-syntax.package = vim-pandoc-syntax;
          };

          # telescope's find_files/live_grep and the chapter picker below shell
          # out to these — kept explicit so this module works even if it's the
          # only dev module imported on a host.
          extraPackages = with pkgs; [
            ripgrep
            fd
          ];

          luaConfigRC.writing-extras = ''
            -- vim-pandoc's folding module closes every markdown section by default,
            -- collapsing a whole chapter into one "## Chapter 1 / 41 lines" line.
            -- Set via vim.g[...] bracket indexing, not the `globals` option — nvf's
            -- globals codegen emits `vim.g.pandoc#modules#disabled = ...`, which is a
            -- Lua syntax error since `#` can't appear in dot-notation.
            vim.g["pandoc#modules#disabled"] = { "folding" }

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
                  vim.wo[self.state.winid].wrap = true
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
    };
}
