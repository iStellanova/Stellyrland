{
  sn,
  ...
}: {
  sn.system = {includes = [sn.homebrew];};

  sn.homebrew.darwin = _: {
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
