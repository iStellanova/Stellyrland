{ inputs, ... }:
{
  pins.cachyos-kernel = {
    url = "https://github.com/xddxdd/nix-cachyos-kernel";
    ref = "release";
  };

  modules.nixos.cachyos-kernel = {
    nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];
# TODO: Remove comments and reinstate code when the damn cache is functional again. Remove on oct. 25th if cache doesn't return.
#     nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
#     nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };
}
