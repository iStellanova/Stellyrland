{ inputs, ... }:
let
  home-manager-config =
    { host, ... }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        overwriteBackup = true;
        extraSpecialArgs = {
          inherit host inputs;
        };
      };
    };
in
{
  modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };
}
