{sn, ...}: let
  idePkgs = pkgs:
    with pkgs; [
      jetbrains.clion
      jetbrains.idea
      jetbrains.pycharm
    ];
in {
  sn.productivity = {includes = [sn.ide-suite];};

  sn.ide-suite.nixos = {pkgs, ...}: {
    environment.systemPackages = idePkgs pkgs;
  };

  sn.ide-suite.darwin = {pkgs, ...}: {
    environment.systemPackages = idePkgs pkgs;

    homebrew.masApps = {
      "Xcode" = 497799835;
    };
  };
}
