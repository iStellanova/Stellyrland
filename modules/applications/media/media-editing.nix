{
  flake.modules.nixos.media-editing = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gimp
      parabolic
    ];
  };

  flake.modules.darwin.media-editing = {
    homebrew.casks = [
      "gimp"
    ];
  };
}
