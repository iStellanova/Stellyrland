_: {
  # NixOS Seahorse Settings
  flake.modules.nixos.seahorse = _: {
    config = {
      programs.seahorse.enable = true;
    };
  };
}
