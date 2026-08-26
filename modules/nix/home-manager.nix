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
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      home-manager-config
    ];
  };

  flake.modules.finix.home-manager = {
    imports = [ ./_finix-home-manager.nix ];
  };

  flake.modules.darwin.home-manager = {
    imports = [
      inputs.home-manager.darwinModules.home-manager
      home-manager-config
    ];
  };
}
