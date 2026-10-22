{ inputs, ... }:
{
  pins.cachyos-kernel = {
    url = "https://github.com/xddxdd/nix-cachyos-kernel";
    ref = "release";
  };

  modules.nixos.cachyos-kernel = {
    nixpkgs.overlays = [ inputs.cachyos-kernel.overlays.pinned ];
# TODO (2026-10-25): Recheck /nix-cache-info and this host's exact CachyOS kernel .narinfo;
# re-enable below only if both are available, otherwise delete this commented fallback.
# Cache: https://attic.xuyh0120.win/lantian
#     nix.settings.substituters = [ "https://attic.xuyh0120.win/lantian" ];
#     nix.settings.trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };
}
