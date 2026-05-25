_: {
  # NixOS IDE Suite Settings
  flake.modules.nixos.ide-suite = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      jetbrains.clion
      jetbrains.idea
      jetbrains.pycharm
    ];
  };

  # Darwin IDE Suite Settings
  flake.modules.darwin.ide-suite = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      jetbrains.clion
      jetbrains.idea
      jetbrains.pycharm
    ];

    homebrew.masApps = {
      "Xcode" = 497799835;
    };
  };
}
