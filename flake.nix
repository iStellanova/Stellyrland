{
  description = "Modular Dendritic NixOS configuration for stellyrland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # TODO: Remove this pin once deno/rusty-v8 build issues are resolved
    nixpkgs-deno.url = "github:nixos/nixpkgs/3e2cf88148e732abc1d259286123e06a9d8c964a";

    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

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
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, home-manager, cachyos-kernel, ... }:
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
            # TODO: Remove this overlay once deno/rusty-v8 build issues are resolved
            ({ inputs, ... }: {
              nixpkgs.overlays = [
                (final: prev: {
                  deno = inputs.nixpkgs-deno.legacyPackages.${prev.stdenv.hostPlatform.system}.deno;
                })
                inputs.cachyos-kernel.overlays.default
              ];
            })
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
