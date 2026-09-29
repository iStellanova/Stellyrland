let
  osShared =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        jetbrains.clion
        jetbrains.pycharm
      ];
    };
in
{
  modules.nixos.ide-suite = { pkgs, ... }: {
    imports = [ osShared ];
    environment.systemPackages = [ pkgs.jetbrains.idea ];
  };

  modules.darwin.ide-suite = {
    imports = [
      osShared
      {
        homebrew.casks = [ "intellij-idea" ];
      }
    ];
  };
}
