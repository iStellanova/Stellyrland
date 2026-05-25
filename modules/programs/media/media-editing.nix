_: {
  # NixOS Media Editing Settings
  flake.modules.nixos.media-editing = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        davinci-resolve
        gimp
        obs-studio
        parabolic
        losslesscut-bin
      ];
    };
  };

  # Darwin Media Editing Settings
  flake.modules.darwin.media-editing = _: {
    config = {
      homebrew.casks = [
        "gimp"
        "obs"
        "losslesscut"
      ];
    };
  };
}
