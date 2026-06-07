_: {
  den.aspects.homebrew.darwin = _: {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        extraFlags = ["--force-cleanup"];
        upgrade = true;
      };
    };
  };
}
