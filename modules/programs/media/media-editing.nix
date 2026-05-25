_: {
  # NixOS Media Editing Settings
  flake.modules.nixos.media-editing = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      davinci-resolve
      gimp
      obs-studio
      parabolic
      losslesscut-bin
    ];
  };

  # Darwin Media Editing Settings
  flake.modules.darwin.media-editing = _: {
    homebrew.casks = [
      "gimp"
      "obs"
      "losslesscut"
    ];
  };
}
