{ self, inputs, ... }: {
  flake = {
    nixosConfigurations.stellyrland = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        lib = self.lib;
        identity = self.lib.mkIdentity inputs.identity false;
        isDarwin = false;
      };
      modules = [
        ../modules/default.nix
        ../hosts/stellyrland/default.nix
        inputs.catppuccin.nixosModules.catppuccin
        inputs.hyprland.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            overwriteBackup = true;
            extraSpecialArgs = {
              inherit inputs;
              identity = self.lib.mkIdentity inputs.identity false;
            };
            users.${(self.lib.mkIdentity inputs.identity false).name}.imports = [
              inputs.catppuccin.homeModules.catppuccin
              inputs.hyprland.homeManagerModules.default
            ];
          };
        }
      ];
    };

    darwinConfigurations.stellyrtop = inputs.nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {
        inherit inputs;
        lib = self.lib;
        identity = self.lib.mkIdentity inputs.identity true;
        isDarwin = true;
      };
      modules = [
        ../modules/default.nix
        ../hosts/stellyrtop/default.nix
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            overwriteBackup = true;
            extraSpecialArgs = {
              inherit inputs;
              identity = self.lib.mkIdentity inputs.identity true;
            };
          };
        }
      ];
    };
  };
}
