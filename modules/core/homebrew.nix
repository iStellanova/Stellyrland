_: {
  # Darwin Homebrew settings
  flake.modules.darwin.homebrew = _: {
    config = {
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          upgrade = true;
        };
      };
    };
  };
}
