_:
let
  osShared = { pkgs, lib, ... }: {
    nix.package = lib.mkDefault pkgs.lix;
    nix.settings.substituters = [ "https://cache.lix.systems" ];
    nix.settings.trusted-public-keys = [
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    ];
  };
in
{
  flake.modules.nixos.lix = {
    imports = [
      osShared
      (_: { nixpkgs.overlays = [ (_final: prev: { nix = prev.lix; }) ]; })
    ];
  };

  flake.modules.darwin.lix = {
    imports = [
      osShared
      (_: {
        nixpkgs.overlays = [ (_final: prev: { nix = prev.lix; }) ];
        nix.enable = true;
      })
    ];
  };
}
