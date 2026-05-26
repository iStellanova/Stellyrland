_: let
  idePkgs = pkgs:
    with pkgs; [
      jetbrains.clion
      jetbrains.idea
      jetbrains.pycharm
    ];
in {
  # NixOS IDE Suite Settings
  flake.modules.nixos.ide-suite = {pkgs, ...}: {
    environment.systemPackages = idePkgs pkgs;
  };

  # Darwin IDE Suite Settings
  flake.modules.darwin.ide-suite = {pkgs, ...}: {
    environment.systemPackages = idePkgs pkgs;

    homebrew.masApps = {
      "Xcode" = 497799835;
    };
  };
}
