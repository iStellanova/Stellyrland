{
  sn,
  ...
}:
{
  sn.nix-base = {
    includes = [ sn.lix ];
  };

  sn.lix.nixos = _: {
    nixpkgs.overlays = [
      (_final: prev: {
        nix = prev.lix;
      })
    ];
  };

  sn.lix.darwin = _: {
    nixpkgs.overlays = [
      (_final: prev: {
        nix = prev.lix;
      })
    ];
    nix.enable = true;
  };

  sn.lix.os =
    {
      pkgs,
      lib,
      ...
    }:
    {
      nix.package = lib.mkDefault pkgs.lix;
      nix.settings.substituters = [ "https://cache.lix.systems" ];
      nix.settings.trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };
}
