_: {
  # Darwin Finance Settings
  flake.modules.darwin.finance = _: {
    config = {
      homebrew.casks = ["quicken"];
    };
  };
}
