{ config, pkgs, ... }:

{
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
        "light" = "Matugen Light";
        "dark" = "Catppuccin Macchiato (Blur)";
      };
      "languages" = {
        "YAML" = {
          "format_on_save" = "off";
        };
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "zed --wait";
    VISUAL = "zed --wait";
  };

  # Themes and colors
  xdg.configFile."zed/themes/colors.css".text = ''
    /* ~/.config/matugen/templates/waybar-colors.css */
    @define-color primary #f0b3e7;
    @define-color primary-container #653661;
    @define-color secondary #dabfd3;
    @define-color background #171216;
    @define-color surface #171216;
    @define-color on-surface #ebdfe6;
    @define-color on-primary #4b1f49;
  '';

  xdg.configFile."zed/themes/matugen.json".text = builtins.toJSON {
    "$schema" = "https://zed.dev/schema/themes/v0.2.0.json";
    "name" = "Matugen";
    "author" = "Matugen";
    "themes" = [
      {
        "name" = "Matugen Dark";
        "appearance" = "dark";
        "style" = {
          "accents" = [ "#ffb1c4" "#e3bdc5" "#edbd92" ];
          "background.appearance" = "opaque";
          "border" = "#514346";
          "border.variant" = "#9e8c8f";
          "border.focused" = "#ffb1c4";
          "border.selected" = "#ffb1c4";
          "border.transparent" = "#51434640";
          "border.disabled" = "#51434660";
          "elevated_surface.background" = "#312829";
          "surface.background" = "#191113";
          "background" = "#191113";
          "element.background" = "#261d1f";
          "element.hover" = "#312829";
          "element.active" = "#3c3234";
          "element.selected" = "#5b3f46";
          "element.disabled" = "#514346";
          "drop_target.background" = "#70334580";
          "ghost_element.background" = null;
          "ghost_element.hover" = "#261d1f80";
          "ghost_element.active" = "#312829";
          "ghost_element.selected" = "#5b3f4680";
          "ghost_element.disabled" = "#51434660";
          "text" = "#efdfe1";
          "text.muted" = "#d6c2c5";
          "text.placeholder" = "#d6c2c599";
          "text.disabled" = "#efdfe160";
          "text.accent" = "#ffb1c4";
          "icon" = "#efdfe1";
          "icon.muted" = "#d6c2c5";
          "icon.disabled" = "#efdfe160";
          "icon.placeholder" = "#d6c2c580";
          "icon.accent" = "#ffb1c4";
          "status_bar.background" = "#191113";
          "title_bar.background" = "#191113";
          "title_bar.inactive_background" = "#191113";
          "toolbar.background" = "#22191b";
          "tab_bar.background" = "#261d1f";
          "tab.inactive_background" = "#22191b";
          "tab.active_background" = "#312829";
          "search.match_background" = "#60401e80";
          "panel.background" = "#22191b";
          "panel.focused_border" = "#ffb1c4";
          "pane.focused_border" = "#ffb1c4";
          "scrollbar.thumb.background" = "#d6c2c580";
          "scrollbar.thumb.hover_background" = "#d6c2c5c0";
          "scrollbar.thumb.border" = "#51434640";
          "scrollbar.track.background" = "#261d1f";
          "scrollbar.track.border" = "#51434620";
          "editor.foreground" = "#efdfe1";
          "editor.background" = "#22191b";
          "editor.gutter.background" = "#22191b";
          "editor.subheader.background" = "#261d1f";
          "editor.indent_guide" = "#51434660";
          "editor.indent_guide_active" = "#9e8c8f";
          "editor.active_line.background" = "#31282980";
          "editor.highlighted_line.background" = "#31282960";
          "editor.line_number" = "#d6c2c5";
          "editor.active_line_number" = "#ffb1c4";
          "editor.invisible" = "#51434680";
          "editor.wrap_guide" = "#51434640";
          "editor.active_wrap_guide" = "#9e8c8f80";
          "editor.document_highlight.read_background" = "#70334560";
          "editor.document_highlight.write_background" = "#5b3f4680";
          "terminal.background" = "#22191b";
          "terminal.foreground" = "#efdfe1";
          "terminal.bright_foreground" = "#efdfe1";
          "terminal.dim_foreground" = "#d6c2c5";
          "terminal.ansi.black" = "#191113";
          "terminal.ansi.bright_black" = "#312829";
          "terminal.ansi.dim_black" = "#191113";
          "terminal.ansi.red" = "#ffb4ab";
          "terminal.ansi.bright_red" = "#ffb4ab";
          "terminal.ansi.dim_red" = "#ffdad6";
          "terminal.ansi.green" = "#edbd92";
          "terminal.ansi.bright_green" = "#edbd92";
          "terminal.ansi.dim_green" = "#ffdcbf";
          "terminal.ansi.yellow" = "#edbd92";
          "terminal.ansi.bright_yellow" = "#ffdcbf";
          "terminal.ansi.dim_yellow" = "#2d1600";
          "terminal.ansi.blue" = "#ffb1c4";
          "terminal.ansi.bright_blue" = "#ffb1c4";
          "terminal.ansi.dim_blue" = "#ffd9e0";
          "terminal.ansi.magenta" = "#e3bdc5";
          "terminal.ansi.bright_magenta" = "#e3bdc5";
          "terminal.ansi.dim_magenta" = "#ffd9e0";
          "terminal.ansi.cyan" = "#ffb1c4";
          "terminal.ansi.bright_cyan" = "#ffd9e0";
          "terminal.ansi.dim_cyan" = "#703345";
          "terminal.ansi.white" = "#efdfe1";
          "terminal.ansi.bright_white" = "#efdfe1";
          "terminal.ansi.dim_white" = "#d6c2c5";
          "link_text.hover" = "#ffb1c4";
          "conflict" = "#ffb4ab";
          "conflict.background" = "#93000a80";
          "conflict.border" = "#ffdad6";
          "created" = "#edbd92";
          "created.background" = "#60401e80";
          "created.border" = "#ffdcbf";
          "deleted" = "#ffb4ab";
          "deleted.background" = "#93000a80";
          "deleted.border" = "#ffdad6";
          "error" = "#ffb4ab";
          "error.background" = "#93000a";
          "error.border" = "#ffdad6";
          "hidden" = "#514346";
          "hidden.border" = "#51434660";
          "hint" = "#ffb1c4";
          "hint.background" = "#70334580";
          "hint.border" = "#ffd9e0";
          "ignored" = "#d6c2c560";
          "ignored.background" = "#51434640";
          "ignored.border" = "#51434640";
          "info" = "#ffb1c4";
          "info.background" = "#70334580";
          "info.border" = "#ffd9e0";
          "modified" = "#e3bdc5";
          "modified.background" = "#5b3f4680";
          "modified.border" = "#ffd9e0";
          "predictive" = "#d6c2c580";
          "predictive.border" = "#9e8c8f";
          "predictive.background" = "#3c323480";
          "renamed" = "#e3bdc5";
          "renamed.border" = "#ffd9e0";
          "renamed.background" = "#5b3f4680";
          "success" = "#edbd92";
          "success.background" = "#60401e80";
          "success.border" = "#ffdcbf";
          "unreachable" = "#d6c2c560";
          "unreachable.background" = "#51434640";
          "unreachable.border" = "#51434660";
          "warning" = "#edbd92";
          "warning.background" = "#60401e80";
          "warning.border" = "#ffdcbf";
          "players" = [
            {
              "cursor" = "#ffb1c4";
              "background" = "#70334580";
              "selection" = "#70334560";
            }
            {
              "cursor" = "#e3bdc5";
              "background" = "#5b3f4680";
              "selection" = "#5b3f4660";
            }
          ];
          "syntax" = {
            "boolean" = { "color" = "#edbd92"; "font_style" = null; "font_weight" = null; };
            "comment" = { "color" = "#d6c2c5"; "font_style" = "italic"; "font_weight" = null; };
            "comment.doc" = { "color" = "#d6c2c5"; "font_style" = "italic"; "font_weight" = null; };
            "constant" = { "color" = "#edbd92"; "font_style" = null; "font_weight" = null; };
            "constructor" = { "color" = "#e3bdc5"; "font_style" = null; "font_weight" = null; };
            "emphasis" = { "color" = "#ffb1c4"; "font_style" = "italic"; "font_weight" = null; };
            "emphasis.strong" = { "color" = "#ffb1c4"; "font_style" = null; "font_weight" = 700; };
            "function" = { "color" = "#ffb1c4"; "font_style" = null; "font_weight" = null; };
            "keyword" = { "color" = "#e3bdc5"; "font_style" = null; "font_weight" = null; };
            "number" = { "color" = "#ffdcbf"; "font_style" = null; "font_weight" = null; };
            "operator" = { "color" = "#d6c2c5"; "font_style" = null; "font_weight" = null; };
            "property" = { "color" = "#efdfe1"; "font_style" = null; "font_weight" = null; };
            "punctuation" = { "color" = "#d6c2c5"; "font_style" = null; "font_weight" = null; };
            "punctuation.bracket" = { "color" = "#ffd9e0"; "font_style" = null; "font_weight" = null; };
            "punctuation.delimiter" = { "color" = "#d6c2c5"; "font_style" = null; "font_weight" = null; };
            "punctuation.list_marker" = { "color" = "#d6c2c5"; "font_style" = null; "font_weight" = null; };
            "punctuation.special" = { "color" = "#e3bdc5"; "font_style" = null; "font_weight" = null; };
            "string" = { "color" = "#edbd92"; "font_style" = null; "font_weight" = null; };
            "string.escape" = { "color" = "#edbd92"; "font_style" = null; "font_weight" = null; };
            "string.regex" = { "color" = "#ffdcbf"; "font_style" = null; "font_weight" = null; };
            "string.special" = { "color" = "#ffdcbf"; "font_style" = null; "font_weight" = null; };
            "string.special.symbol" = { "color" = "#edbd92"; "font_style" = null; "font_weight" = null; };
            "tag" = { "color" = "#e3bdc5"; "font_style" = null; "font_weight" = null; };
            "text.literal" = { "color" = "#edbd92"; "font_style" = null; "font_weight" = null; };
            "type" = { "color" = "#ffd9e0"; "font_style" = null; "font_weight" = null; };
            "variable" = { "color" = "#efdfe1"; "font_style" = null; "font_weight" = null; };
            "variable.special" = { "color" = "#ffb1c4"; "font_style" = null; "font_weight" = null; };
          };
        };
      }
      {
        "name" = "Matugen Light";
        "appearance" = "light";
        "style" = {
          "accents" = [ "#8d4a5c" "#75565d" "#7b5733" ];
          "background.appearance" = "opaque";
          "border" = "#d6c2c5";
          "border.variant" = "#847376";
          "border.focused" = "#8d4a5c";
          "border.selected" = "#8d4a5c";
          "border.transparent" = "#d6c2c540";
          "border.disabled" = "#d6c2c560";
          "elevated_surface.background" = "#f5e4e6";
          "surface.background" = "#fff8f8";
          "background" = "#fff8f8";
          "element.background" = "#fbeaec";
          "element.hover" = "#f5e4e6";
          "element.active" = "#efdfe1";
          "element.selected" = "#ffd9e0";
          "element.disabled" = "#f3dde1";
          "drop_target.background" = "#ffd9e080";
          "ghost_element.background" = null;
          "ghost_element.hover" = "#fbeaec80";
          "ghost_element.active" = "#f5e4e6";
          "ghost_element.selected" = "#ffd9e080";
          "ghost_element.disabled" = "#f3dde160";
          "text" = "#22191b";
          "text.muted" = "#514346";
          "text.placeholder" = "#51434699";
          "text.disabled" = "#22191b60";
          "text.accent" = "#8d4a5c";
          "icon" = "#22191b";
          "icon.muted" = "#514346";
          "icon.disabled" = "#22191b60";
          "icon.placeholder" = "#51434680";
          "icon.accent" = "#8d4a5c";
          "status_bar.background" = "#fff8f8";
          "title_bar.background" = "#fff8f8";
          "title_bar.inactive_background" = "#fff8f8";
          "toolbar.background" = "#fff0f2";
          "tab_bar.background" = "#fbeaec";
          "tab.inactive_background" = "#fff0f2";
          "tab.active_background" = "#f5e4e6";
          "search.match_background" = "#ffdcbf80";
          "panel.background" = "#fff0f2";
          "panel.focused_border" = "#8d4a5c";
          "pane.focused_border" = "#8d4a5c";
          "scrollbar.thumb.background" = "#51434680";
          "scrollbar.thumb.hover_background" = "#514346c0";
          "scrollbar.thumb.border" = "#d6c2c540";
          "scrollbar.track.background" = "#fbeaec";
          "scrollbar.track.border" = "#d6c2c520";
          "editor.foreground" = "#22191b";
          "editor.background" = "#fff0f2";
          "editor.gutter.background" = "#fff0f2";
          "editor.subheader.background" = "#fbeaec";
          "editor.indent_guide" = "#d6c2c560";
          "editor.indent_guide_active" = "#847376";
          "editor.active_line.background" = "#f5e4e680";
          "editor.highlighted_line.background" = "#f5e4e660";
          "editor.line_number" = "#514346";
          "editor.active_line_number" = "#8d4a5c";
          "editor.invisible" = "#d6c2c580";
          "editor.wrap_guide" = "#d6c2c540";
          "editor.active_wrap_guide" = "#84737680";
          "editor.document_highlight.read_background" = "#ffd9e060";
          "editor.document_highlight.write_background" = "#ffd9e080";
          "terminal.background" = "#fff0f2";
          "terminal.foreground" = "#22191b";
          "terminal.bright_foreground" = "#22191b";
          "terminal.dim_foreground" = "#514346";
          "terminal.ansi.black" = "#fff8f8";
          "terminal.ansi.bright_black" = "#f5e4e6";
          "terminal.ansi.dim_black" = "#fff8f8";
          "terminal.ansi.red" = "#ba1a1a";
          "terminal.ansi.bright_red" = "#ba1a1a";
          "terminal.ansi.dim_red" = "#410002";
          "terminal.ansi.green" = "#7b5733";
          "terminal.ansi.bright_green" = "#7b5733";
          "terminal.ansi.dim_green" = "#2d1600";
          "terminal.ansi.yellow" = "#edbd92";
          "terminal.ansi.bright_yellow" = "#ffdcbf";
          "terminal.ansi.dim_yellow" = "#2d1600";
          "terminal.ansi.blue" = "#8d4a5c";
          "terminal.ansi.bright_blue" = "#8d4a5c";
          "terminal.ansi.dim_blue" = "#3a071a";
          "terminal.ansi.magenta" = "#75565d";
          "terminal.ansi.bright_magenta" = "#75565d";
          "terminal.ansi.dim_magenta" = "#2b151b";
          "terminal.ansi.cyan" = "#ffb1c4";
          "terminal.ansi.bright_cyan" = "#ffd9e0";
          "terminal.ansi.dim_cyan" = "#703345";
          "terminal.ansi.white" = "#22191b";
          "terminal.ansi.bright_white" = "#22191b";
          "terminal.ansi.dim_white" = "#514346";
          "link_text.hover" = "#8d4a5c";
          "conflict" = "#ba1a1a";
          "conflict.background" = "#ffdad680";
          "conflict.border" = "#410002";
          "created" = "#7b5733";
          "created.background" = "#ffdcbf80";
          "created.border" = "#2d1600";
          "deleted" = "#ba1a1a";
          "deleted.background" = "#ffdad680";
          "deleted.border" = "#410002";
          "error" = "#ba1a1a";
          "error.background" = "#ffdad6";
          "error.border" = "#410002";
          "hidden" = "#d6c2c5";
          "hidden.border" = "#d6c2c560";
          "hint" = "#8d4a5c";
          "hint.background" = "#ffd9e080";
          "hint.border" = "#3a071a";
          "ignored" = "#51434660";
          "ignored.background" = "#f3dde140";
          "ignored.border" = "#d6c2c540";
          "info" = "#8d4a5c";
          "info.background" = "#ffd9e080";
          "info.border" = "#3a071a";
          "modified" = "#75565d";
          "modified.background" = "#ffd9e080";
          "modified.border" = "#2b151b";
          "predictive" = "#51434680";
          "predictive.border" = "#847376";
          "predictive.background" = "#efdfe180";
          "renamed" = "#75565d";
          "renamed.border" = "#2b151b";
          "renamed.background" = "#ffd9e080";
          "success" = "#7b5733";
          "success.background" = "#ffdcbf80";
          "success.border" = "#2d1600";
          "unreachable" = "#51434660";
          "unreachable.background" = "#f3dde140";
          "unreachable.border" = "#d6c2c560";
          "warning" = "#edbd92";
          "warning.background" = "#ffdcbf80";
          "warning.border" = "#2d1600";
          "players" = [
            {
              "cursor" = "#8d4a5c";
              "background" = "#ffd9e080";
              "selection" = "#ffd9e060";
            }
            {
              "cursor" = "#75565d";
              "background" = "#ffd9e080";
              "selection" = "#ffd9e060";
            }
          ];
          "syntax" = {
            "boolean" = { "color" = "#7b5733"; "font_style" = null; "font_weight" = null; };
            "comment" = { "color" = "#514346"; "font_style" = "italic"; "font_weight" = null; };
            "comment.doc" = { "color" = "#514346"; "font_style" = "italic"; "font_weight" = null; };
            "constant" = { "color" = "#7b5733"; "font_style" = null; "font_weight" = null; };
            "constructor" = { "color" = "#75565d"; "font_style" = null; "font_weight" = null; };
            "emphasis" = { "color" = "#8d4a5c"; "font_style" = "italic"; "font_weight" = null; };
            "emphasis.strong" = { "color" = "#8d4a5c"; "font_style" = null; "font_weight" = 700; };
            "function" = { "color" = "#8d4a5c"; "font_style" = null; "font_weight" = null; };
            "keyword" = { "color" = "#75565d"; "font_style" = null; "font_weight" = null; };
            "number" = { "color" = "#ffdcbf"; "font_style" = null; "font_weight" = null; };
            "operator" = { "color" = "#514346"; "font_style" = null; "font_weight" = null; };
            "property" = { "color" = "#22191b"; "font_style" = null; "font_weight" = null; };
            "punctuation" = { "color" = "#514346"; "font_style" = null; "font_weight" = null; };
            "punctuation.bracket" = { "color" = "#ffd9e0"; "font_style" = null; "font_weight" = null; };
            "punctuation.delimiter" = { "color" = "#514346"; "font_style" = null; "font_weight" = null; };
            "punctuation.list_marker" = { "color" = "#514346"; "font_style" = null; "font_weight" = null; };
            "punctuation.special" = { "color" = "#75565d"; "font_style" = null; "font_weight" = null; };
            "string" = { "color" = "#7b5733"; "font_style" = null; "font_weight" = null; };
            "string.escape" = { "color" = "#edbd92"; "font_style" = null; "font_weight" = null; };
            "string.regex" = { "color" = "#ffdcbf"; "font_style" = null; "font_weight" = null; };
            "string.special" = { "color" = "#2d1600"; "font_style" = null; "font_weight" = null; };
            "string.special.symbol" = { "color" = "#7b5733"; "font_style" = null; "font_weight" = null; };
            "tag" = { "color" = "#75565d"; "font_style" = null; "font_weight" = null; };
            "text.literal" = { "color" = "#7b5733"; "font_style" = null; "font_weight" = null; };
            "type" = { "color" = "#ffd9e0"; "font_style" = null; "font_weight" = null; };
            "variable" = { "color" = "#22191b"; "font_style" = null; "font_weight" = null; };
            "variable.special" = { "color" = "#8d4a5c"; "font_style" = null; "font_weight" = null; };
          };
        };
      }
    ];
  };
}
