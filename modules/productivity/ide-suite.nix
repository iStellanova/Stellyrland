{sn, ...}: let
  idePkgs = pkgs:
    with pkgs; [
      jetbrains.clion
      jetbrains.idea
      jetbrains.pycharm
    ];
in {
  sn.productivity = {includes = [sn.ide-suite];};

  sn.ide-suite.os = {pkgs, ...}: {
    environment.systemPackages = idePkgs pkgs;
  };

  sn.ide-suite.darwin = _: {
    homebrew.masApps = {
      "Xcode" = 497799835;
    };
  };
}
