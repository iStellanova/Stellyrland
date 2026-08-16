{
  flake.modules.nixos.media-editing = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      losslesscut-bin
      gimp
      parabolic
    ];
  };

  flake.modules.darwin.media-editing = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.losslesscut-bin ];
    homebrew.casks = [
      "gimp"
    ];
  };
}
