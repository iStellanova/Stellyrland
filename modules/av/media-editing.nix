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
    ];
  };

  sn.media-editing.darwin = _: {
    homebrew.casks = [
      "gimp"
      "obs"
    ];
  };

  sn.media-editing.os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      losslesscut-bin
    ];
  };
}
