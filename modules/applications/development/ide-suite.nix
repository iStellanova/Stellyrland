let
  osShared =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        jetbrains.clion
        (
          if stdenv.hostPlatform.isDarwin then
            # TODO(pycharm): remove when the Darwin package restores its Cython helper path.
            jetbrains.pycharm.overrideAttrs (old: {
              nativeBuildInputs = lib.remove jetbrains.cythonDebugSpeedupsHook old.nativeBuildInputs;
            })
          else
            jetbrains.pycharm
        )
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
        homebrew.casks = [
          "intellij-idea"
        ];
      }
    ];
  };
}
