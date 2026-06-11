{
  sn,
  ...
}: {
  sn.av = {includes = [sn.background-sounds];};

  sn.background-sounds.darwin = _: {
    homebrew.masApps = {
      "Noizio Lite" = 1481029536;
    };
  };

  sn.background-sounds.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.blanket;
  };
}
