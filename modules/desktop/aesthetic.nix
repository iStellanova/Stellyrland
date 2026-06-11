{sn, ...}: let
  aestheticPkgs = pkgs:
    with pkgs; [
      peaclock

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
  sn.desktop = {includes = [sn.aesthetic];};

  sn.aesthetic.nixos = {pkgs, ...}: {
    environment.systemPackages = aestheticPkgs pkgs;
  };

  sn.aesthetic.darwin = {pkgs, ...}: {
    environment.systemPackages = aestheticPkgs pkgs;
  };
}
