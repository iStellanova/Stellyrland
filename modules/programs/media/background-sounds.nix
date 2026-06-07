_: {
  den.aspects.background-sounds.darwin = _: {
    homebrew.masApps = {
      "Noizio Lite" = 1481029536;
    };
  };

  den.aspects.background-sounds.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.blanket;
  };
}
