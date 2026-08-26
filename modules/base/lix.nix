{
  flake.modules.nixos.lix = { pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.lix;
    nixpkgs.overlays = [ (_final: prev: { nix = prev.lix; }) ];
  };

  flake.modules.finix.lix = { pkgs, ... }: {
    services.nix-daemon.package = pkgs.lix;
  };

  flake.modules.darwin.lix = { pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.lix;
    nixpkgs.overlays = [ (_final: prev: { nix = prev.lix; }) ];
    nix.enable = true;
  };
}
