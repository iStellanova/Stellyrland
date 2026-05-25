_: {
  # NixOS Options Declaration
  flake.modules.nixos.writing = _: {
  };

  # Darwin Writing Settings
  flake.modules.darwin.writing = _: {
    config = {
      homebrew.masApps = {
        "Beat" = 1549538329;
        "Essayist" = 1537845384;
      };
    };
  };
}
