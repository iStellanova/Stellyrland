_: {
  # NixOS School Settings
  flake.modules.nixos.school = {pkgs, ...}: {
    config = {
      environment.systemPackages = [pkgs.zoom-us];
    };
  };

  # Darwin School Settings
  flake.modules.darwin.school = _: {
    config = {
      homebrew.casks = ["zoom"];
      homebrew.masApps = {
        "School Assistant" = 1465687472;
      };
    };
  };
}
