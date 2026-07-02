{ sn, ... }: {
  sn.av = {
    includes = [ sn.media-editing ];
  };

  sn.media-editing.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      davinci-resolve
      gimp
      obs-studio
      parabolic
      losslesscut-bin
    ];
  };

  sn.media-editing.darwin = _: {
    homebrew.casks = [
      "gimp"
      "obs"
      "losslesscut"
    ];
  };
}
