{
  sn,
  ...
}: {
  sn.productivity = {includes = [sn.school];};

  sn.school.nixos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.zoom-us];
  };

  sn.school.darwin = _: {
    homebrew.casks = ["zoom"];
    homebrew.masApps = {
      "School Assistant" = 1465687472;
    };
  };
}
