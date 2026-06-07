_: let
  idePkgs = pkgs:
    with pkgs; [
      jetbrains.clion
      jetbrains.idea
      jetbrains.pycharm
    ];
in {
  den.aspects.ide-suite.nixos = {pkgs, ...}: {
    environment.systemPackages = idePkgs pkgs;
  };

  den.aspects.ide-suite.darwin = {pkgs, ...}: {
    environment.systemPackages = idePkgs pkgs;

    homebrew.masApps = {
      "Xcode" = 497799835;
    };
  };
}
