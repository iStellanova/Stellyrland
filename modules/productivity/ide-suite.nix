{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.ide-suite ];
  };

  sn.ide-suite.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      jetbrains.clion
      jetbrains.idea
      jetbrains.pycharm
    ];
  };

  sn.ide-suite.darwin = _: {
    homebrew.casks = [
      "clion"
      "intellij-idea-ce"
      "pycharm-ce"
    ];
    homebrew.masApps = {
      "Xcode" = 497799835;
    };
  };
}
