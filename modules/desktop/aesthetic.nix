_: let
  aestheticPkgs = pkgs:
    with pkgs; [
      peaclock # A colorful clock, timer, and stopwatch for the terminal

      # Custom / Git Builds
      (python3Packages.buildPythonApplication {
        pname = "terminal-rain-lightning";
        version = "0.1.0";
        src = fetchFromGitHub {
          owner = "rmaake1";
          repo = "terminal-rain-lightning";
          rev = "cc3aa19e1e9aec628a608b0ca6b7c475cce98c05";
          hash = "sha256-GJvGnvo78l4RK2Y9ACbqOXHLQkNtIwIktbm/FK1vOcc=";
        };
        pyproject = true;
        nativeBuildInputs = [python3Packages.setuptools python3Packages.wheel];
      })
    ];
in {
  # NixOS Aesthetic Settings
  flake.modules.nixos.aesthetic = {pkgs, ...}: {
    config.environment.systemPackages = aestheticPkgs pkgs;
  };

  # Darwin Aesthetic Settings
  flake.modules.darwin.aesthetic = {pkgs, ...}: {
    config.environment.systemPackages = aestheticPkgs pkgs;
  };
}
