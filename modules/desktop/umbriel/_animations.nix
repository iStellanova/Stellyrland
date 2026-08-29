{
  programs.umbriel.settings.animation = {
    windows_in = {
      enabled = true;
      duration_ms = 250;
      curve = "easeout";
      style = "popin";
      scale = 0.6;
    };

    windows_out = {
      enabled = true;
      duration_ms = 250;
      curve = "easeout";
      style = "fade";
    };

    windows_move = {
      curve = "snappy";
    };

    workspaces = {
      enabled = true;
      duration_ms = 250;
      curve = "snappy";
    };

    scratchpad = {
      enabled = true;
      duration_ms = 250;
      curve = "easeout";
      dim = 0.2;
    };

    border = {
      enabled = true;
      duration_ms = 250;
      curve = "easeout";
    };
  };
}
