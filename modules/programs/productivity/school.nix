_: {
  den.aspects.school.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.zoom-us];
  };

  den.aspects.school.darwin = _: {
    homebrew.casks = ["zoom"];
    homebrew.masApps = {
      "School Assistant" = 1465687472;
    };
  };
}
