{ inputs, ... }:
let
  aestheticPkgs =
    pkgs: with pkgs; [
      peaclock

      (python3Packages.buildPythonApplication {
        pname = "terminal-rain-lightning";
        version = "0.1.0";
        src = inputs.terminal-rain-lightning;
        pyproject = true;
        nativeBuildInputs = [
          python3Packages.setuptools
          python3Packages.wheel
        ];
      })
    ];
  osShared = { pkgs, ... }: {
    environment.systemPackages = aestheticPkgs pkgs;
  };
in
{
  flake-file.inputs.terminal-rain-lightning = {
    url = "github:rmaake1/terminal-rain-lightning";
    flake = false;
  };

  flake.modules.nixos.aesthetic = osShared;
  flake.modules.darwin.aesthetic = osShared;
}
