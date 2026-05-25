_: {
  # NixOS Options Declaration
  flake.modules.nixos.finance = _: {
  };

  # Darwin Finance Settings
  flake.modules.darwin.finance = _: {
    config = {
      homebrew.casks = ["quicken"];
    };
  };
}
