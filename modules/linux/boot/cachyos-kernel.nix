{ inputs, ... }:
{
  pins.cachyos-kernel = {
    url = "https://github.com/xddxdd/nix-cachyos-kernel";
    ref = "release";
  };

  modules.nixos.cachyos-kernel = {
    nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];
    nix.settings = {
      extra-substituters = [ "https://cache.lantian.pub/lantian" ];
      extra-trusted-public-keys = [ "lantian:WVGO7vsRMSEN+h7Lp7kv6SAmrkEXgUGbbXm7jMDjBuQ=" ];
    };
  };
}
