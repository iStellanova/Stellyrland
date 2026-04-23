{
  description = "Modular Dendritic NixOS configuration for stellyrland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:youwen5/zen-browser-flake";

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-nix-monitor = {
      url = "github:caesar-admin/Noctalia-Nix-Monitor";
      flake = false;
    };

    qs-hyprview-src = {
      url = "github:dom0/qs-hyprview";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, home-manager, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake = {
        nixosConfigurations.stellyrland = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            # Extend lib with our custom scan function
            lib = nixpkgs.lib.extend (self: super: (import ./lib/default.nix { lib = self; }));
          };
          modules = [
            ./modules/default.nix
            ./hosts/stellyrland/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                backupFileExtension = "backup";
                overwriteBackup = true;
              };
            }
          ];
        };
      };
    };
}
