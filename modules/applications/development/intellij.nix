{
  modules.nixos.intellij = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.jetbrains.idea ];
  };

  modules.darwin.intellij = {
    homebrew.casks = [ "intellij-idea" ];
  };
}
