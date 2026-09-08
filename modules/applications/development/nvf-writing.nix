{ inputs, ... }:
{
  flake-file.inputs.nvf = {
    url = "github:notashelf/nvf";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # programs.nvf is a singleton. Build wvim directly to isolate it from nvf-ide,
  # including its ~/.config/wvim state.
  flake.modules.homeManager.nvf-writing =
    { pkgs, ... }:
    let
      wvim = inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          {
            mnw.appName = "wvim";

            vim = {
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
                statusline = "%f %y%=%{wordcount().words} words  %l:%c";
              };

              undoFile.enable = true;

              utility.oil-nvim.enable = true;

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

              # Telescope embeds fd; the chapter picker below shells out to rg.
              extraPackages = [ pkgs.ripgrep ];

              luaConfigRC.writing-extras = ''
                -- Disables vim-pandoc's folding (collapses every section on open). Bracket
                -- indexing, not `globals` — nvf's codegen can't dot-emit a key with `#` in it.
                vim.g["pandoc#modules#disabled"] = { "folding" }

                -- Autosave on focus/buffer switch.
                vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
                  command = "silent! wall",
                })

                -- Chapter picker (<leader>fc): find_files over *.md, previewing frontmatter
                -- (plain `key: value` lines between `---` markers) instead of raw content.
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
          }
        ];
      };

      wvim-bin = pkgs.runCommand "wvim" { } ''
        mkdir -p $out/bin
        ln -s ${wvim.neovim}/bin/nvim $out/bin/wvim
      '';
    in
    {
      home.packages = [ wvim-bin ];
    };
}
