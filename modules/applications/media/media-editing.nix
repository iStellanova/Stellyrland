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
            gimp
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
        ];
      })
    ];
  };
}
