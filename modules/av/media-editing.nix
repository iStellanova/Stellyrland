_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      losslesscut-bin
    ];
  };
in
{
  flake.modules.nixos.media-editing = {
    imports = [
      osShared
      (
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            davinci-resolve
            gimp
            obs-studio
            parabolic
          ];
        }
      )
    ];
  };

  flake.modules.darwin.media-editing = {
    imports = [
      osShared
      (_: {
        homebrew.casks = [
          "gimp"
          "obs"
        ];
      })
    ];
  };
}
