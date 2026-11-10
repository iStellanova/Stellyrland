{ inputs, ... }:
{
  pins.bootvine = {
    url = "https://codeberg.org/wvhulle/bootvine";
    follows.nixpkgs = "nixpkgs";
    importable = true;
  };

  modules.nixos.bootvine = {
    imports = [ inputs.bootvine.nixosModules.default ];
    services.bootvine.enable = true;
  };
}
