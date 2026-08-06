{
  name = "catppuccin-macchiato-sapphire";
  description = "Catppuccin Macchiato with Sapphire accents";

  colors = {
    background = "#24273a";

    ui_accent = "#8aadf4";
    ui_tool = "#8aadf4";
    banner_accent = "#8aadf4";

    banner_title = "#cad3f5";
    banner_text = "#cad3f5";
    ui_text = "#cad3f5";
    ui_primary = "#cad3f5";
    ui_label = "#b8c0e0";
    banner_dim = "#a5adcb";
    # The Ink TUI reserves its own startup card; matching its structural rules
    # to the base surface keeps the working transcript visually quiet.
    banner_border = "#24273a";
    ui_border = "#24273a";

    ui_ok = "#a6da95";
    ui_warn = "#eed49f";
    ui_error = "#ed8796";

    prompt = "#8aadf4";
    input_rule = "#8aadf4";
    response_border = "#24273a";
    status_bar_bg = "#1e2030";
    status_bar_text = "#cad3f5";
    status_bar_good = "#a6da95";
    status_bar_warn = "#eed49f";
    status_bar_critical = "#ed8796";
    session_label = "#8aadf4";
    session_border = "#24273a";

    # The TUI uses these as line backgrounds; keep them dark enough that the
    # brighter word colors remain readable in inline diffs.
    diff_added = "#2d4a3a";
    diff_removed = "#4d303b";
    diff_added_word = "#a6da95";
    diff_removed_word = "#ed8796";

    syntax_string = "#a6da95";
    syntax_number = "#f5a97f";
    syntax_keyword = "#c6a0f6";
    syntax_comment = "#939ab7";
    ui_thinking = "#a5adcb";

    status_bar_strong = "#8aadf4";
    status_bar_dim = "#a5adcb";
    status_bar_bad = "#f5a97f";
    voice_status_bg = "#1e2030";
    selection_bg = "#494d64";
    completion_menu_bg = "#1e2030";
    completion_menu_current_bg = "#494d64";
    completion_menu_meta_bg = "#1e2030";
    completion_menu_meta_current_bg = "#494d64";
    shell_dollar = "#8aadf4";
  };

  branding = {
    agent_name = "Stellxie";
    welcome = "";
    goodbye = "";
    response_label = "";
    prompt_symbol = "›";
    help_header = "Commands";
  };

  banner_logo = "";
  banner_hero = "";

  tool_prefix = "·";

  spinner = {
    waiting_faces = [ "·" ];
    thinking_faces = [
      "·"
      "∙"
      "●"
      "∙"
    ];
    thinking_verbs = [ "working" ];
    wings = [ ];
  };
}
