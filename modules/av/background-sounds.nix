{ sn, ... }: {
  sn.av = {
    includes = [ sn.background-sounds ];
  };

  sn.background-sounds.darwin = _: {
    homebrew.casks = [
      "blankie"
    ];
  };

  sn.background-sounds.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = lib.optional pkgs.stdenv.isLinux pkgs.blanket;
    };
}
