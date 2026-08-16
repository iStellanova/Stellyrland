{
  flake.modules.darwin.background-sounds = {
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
      home.packages = lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.blanket;
    };
}
