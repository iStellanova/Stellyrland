_: {
  flake.modules.darwin.background-sounds = _: {
    homebrew.casks = [
      "blankie"
    ];
  };

  flake.modules.homeManager.background-sounds =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = lib.optional pkgs.stdenv.isLinux pkgs.blanket;
    };
}
