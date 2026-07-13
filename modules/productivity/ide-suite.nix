_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      jetbrains.clion
      jetbrains.pycharm
    ];
  };
in
{
  flake.modules.nixos.ide-suite = {
    imports = [
      osShared
      (
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.jetbrains.idea ];
        }
      )
    ];
  };

  flake.modules.darwin.ide-suite = {
    imports = [
      osShared
      (_: {
        homebrew.casks = [
          "intellij-idea"
        ];
      })
    ];
  };
}
