_: {
  den.aspects.media-editing.nixos = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      davinci-resolve
      gimp
      obs-studio
      parabolic
      losslesscut-bin
    ];
  };

  den.aspects.media-editing.darwin = _: {
    homebrew.casks = [
      "gimp"
      "obs"
      "losslesscut"
    ];
  };
}
