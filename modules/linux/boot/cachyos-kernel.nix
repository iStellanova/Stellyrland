{ inputs, ... }:
{
  flake-file.inputs.cachyos-kernel = {
    url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  flake.modules.nixos.cachyos-kernel = {
    nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];
    nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
    nix.settings.trusted-public-keys = [
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };
}
