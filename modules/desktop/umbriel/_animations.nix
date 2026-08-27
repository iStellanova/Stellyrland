{
  programs.umbriel.settings.animation = {
    enabled = true;
    duration_ms = 250;
    curve = "bezier: 0.05,0.7,0.1,1";

    windows_in = {
      enabled = true;
      duration_ms = 250;
      curve = "bezier: 0.05,0.9,0.1,1";
      style = "popin";
      scale = 0.6;
    };

    windows_out = {
      enabled = true;
      duration_ms = 250;
      curve = "bezier: 0.3,0,0.8,0.15";
      style = "fade";
    };

    windows_move = {
      enabled = true;
      duration_ms = 250;
      curve = "bezier: 0.05,0.7,0.1,1";
    };

    workspaces = {
      enabled = true;
      duration_ms = 200;
      curve = "bezier: 0.16,1,0.3,1";
    };

    scratchpad = {
      enabled = true;
      duration_ms = 250;
      curve = "bezier: 0.05,0.7,0.1,1";
      dim = 0.2;
    };

    fade = {
      enabled = true;
      duration_ms = 250;
      curve = "bezier: 0.05,0.7,0.1,1";
    };

    border = {
      enabled = true;
      duration_ms = 250;
      curve = "bezier: 0.26,0.26,0.15,1";
    };
  };
}
