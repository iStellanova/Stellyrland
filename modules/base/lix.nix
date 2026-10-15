let
  lixOverlay = final: prev: {
    # TODO(lix): Remove this override once nixpkgs stops passing the removed
    # -Dmimalloc option to Lix.
    lix = prev.lix.overrideAttrs (old: {
      mesonFlags = prev.lib.filter (flag: !prev.lib.hasPrefix "-Dmimalloc=" flag) old.mesonFlags;
    });
    nix = final.lix;
  };
in
{
  modules.nixos.lix = { pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.lix;
    nixpkgs.overlays = [ lixOverlay ];
  };

  modules.darwin.lix = { pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.lix;
    nixpkgs.overlays = [ lixOverlay ];
    nix.enable = true;
  };
}
