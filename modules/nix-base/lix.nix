{
  sn,
  inputs,
  ...
}: {
  sn.nix-base = {includes = [sn.lix];};

  flake-file.inputs.lix-module = {
    url = "git+https://git.lix.systems/lix-project/nixos-module";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.lix.nixos = {
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.lix-module.nixosModules.lixFromNixpkgs];

    # Belt-and-suspenders for flake-parts setups where nixpkgs.overlays is bypassed.
    nix.package = lib.mkDefault pkgs.lix;
    nix.settings.substituters = ["https://cache.lix.systems"];
    nix.settings.trusted-public-keys = ["cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="];
  };
}
