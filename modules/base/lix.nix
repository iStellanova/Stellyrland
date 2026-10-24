let
  lixOverlay = final: prev: {
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
