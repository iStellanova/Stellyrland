{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.ide-suite ];
  };

  sn.ide-suite.os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      jetbrains.clion
      jetbrains.pycharm
    ];
  };

  sn.ide-suite.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.jetbrains.idea ];
  };

  sn.ide-suite.darwin = _: {
    homebrew.casks = [
      "intellij-idea"
    ];
  };
}
