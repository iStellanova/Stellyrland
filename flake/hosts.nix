{ self, inputs, ... }: 
let
  mkHost = { system, isDarwin, hostname, extraModules ? [] }:
    let
      identity = self.lib.mkIdentity inputs.identity isDarwin;
      coreBuilder = if isDarwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem;
      hmModule = if isDarwin then inputs.home-manager.darwinModules.home-manager else inputs.home-manager.nixosModules.home-manager;
    in
    coreBuilder {
      inherit system;
      specialArgs = {
        inherit inputs;
        lib = self.lib;
        inherit identity isDarwin;
      };
      modules = [
        ../modules/default.nix
        ../hosts/${hostname}/default.nix
        hmModule
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            overwriteBackup = true;
            extraSpecialArgs = {
              inherit inputs identity;
            };
          };
        }
      ] ++ extraModules;
    };
in {
  flake = {
    # Export the dendritic module framework
    nixosModules.default = ../modules/default.nix;

    nixosConfigurations.stellyrland = mkHost {
      system = "x86_64-linux";
      isDarwin = false;
      hostname = "stellyrland";
      extraModules = [
        inputs.catppuccin.nixosModules.catppuccin
        inputs.hyprland.nixosModules.default
        inputs.echo.nixosModules.default
      ];
    };

    darwinConfigurations.stellyrtop = mkHost {
      system = "aarch64-darwin";
      isDarwin = true;
      hostname = "stellyrtop";
      extraModules = [
        inputs.mac-app-util.darwinModules.default
      ];
    };
  };
}
