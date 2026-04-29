{ config, lib, pkgs, ... }:

{
  options.aspects.programs.aesthetic.enable = lib.mkEnableOption "Aesthetic and toy CLI utilities";

  config = lib.mkIf config.aspects.programs.aesthetic.enable {
    environment.systemPackages = with pkgs; [
      peaclock                 # A colorful clock, timer, and stopwatch for the terminal

      # Custom / Git Builds
      (python3Packages.buildPythonApplication {
        pname = "terminal-rain-lightning";
        version = "0.1.0";
        src = fetchFromGitHub {
          owner = "rmaake1";
          repo = "terminal-rain-lightning";
          rev = "master";
          sha256 = "1r4ccxnrww1wn35sis6qmqlkn70735izhii0n3i55nfz8xs2l4w2";
        };
        pyproject = true;
        nativeBuildInputs = [ python3Packages.setuptools python3Packages.wheel ];
      })
    ];
  };
}
