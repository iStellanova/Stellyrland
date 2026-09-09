let
  osShared =
    { pkgs, ... }:
    let
      pycharm =
        if pkgs.stdenv.hostPlatform.isDarwin then
          pkgs.jetbrains.pycharm.overrideAttrs (old: {
            # TODO(nixpkgs): Remove when cythonDebugSpeedupsHook supports PyCharm 2026.2's python-ce layout.
            nativeBuildInputs = pkgs.lib.remove pkgs.jetbrains.cythonDebugSpeedupsHook old.nativeBuildInputs;
          })
        else
          pkgs.jetbrains.pycharm;
    in
    {
      environment.systemPackages = with pkgs; [
        jetbrains.clion
        pycharm
      ];
    };
in
{
  flake.modules.nixos.ide-suite = { pkgs, ... }: {
    imports = [ osShared ];
    environment.systemPackages = [ pkgs.jetbrains.idea ];
  };

  flake.modules.darwin.ide-suite = {
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
