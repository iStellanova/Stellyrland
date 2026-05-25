_: {
  # Darwin Background Sounds Settings
  flake.modules.darwin.background-sounds = _: {
    config = {
      homebrew.masApps = {
        "Noizio Lite" = 1481029536;
      };
    };
  };

  # Home Manager Background Sounds Settings
  flake.modules.homeManager.background-sounds = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.optional pkgs.stdenv.isLinux pkgs.blanket;
  };
}
