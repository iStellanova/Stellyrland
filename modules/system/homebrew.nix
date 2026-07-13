_: {
  flake.modules.darwin.homebrew = _: {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
        extraFlags = [ "--force-cleanup" ];
        upgrade = true;
      };
    };
  };
}
