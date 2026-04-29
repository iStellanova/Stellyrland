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

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    identity.url = "git+ssh://git@github.com/iStellanova/stellyrdentity.git";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, home-manager, cachyos-kernel, nix-darwin, mac-app-util, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      flake = {
        nixosConfigurations.stellyrland = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            identity = {
              name = inputs.identity.nixosName;
              email = inputs.identity.userEmail;
              gitName = inputs.identity.gitName;
              home = "/home/${inputs.identity.nixosName}";
            };
            isDarwin = false;
            # Extend lib with our custom scan function
            lib = nixpkgs.lib.extend (self: super: (import ./lib/default.nix { lib = self; }));
          };
          modules = [
            # TODO: Remove this overlay once deno/rusty-v8 build issues are resolved
            ({ inputs, ... }: {
              nixpkgs.overlays = [
                (final: prev: {
                  deno = inputs.nixpkgs-deno.legacyPackages.${prev.stdenv.hostPlatform.system}.deno;
                  # TODO: Remove direnv override once macOS/Sandbox hangs are resolved upstream
                  direnv = prev.direnv.overrideAttrs (old: { doCheck = false; });
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
                extraSpecialArgs = { inherit inputs; identity = { name = inputs.identity.nixosName; email = inputs.identity.userEmail; gitName = inputs.identity.gitName; home = "/home/${inputs.identity.nixosName}"; }; };
                backupFileExtension = "backup";
                overwriteBackup = true;
              };
            }
          ];
        };

        darwinConfigurations.stellyrtop = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = {
            inherit inputs;
            identity = {
              name = inputs.identity.darwinName;
              email = inputs.identity.userEmail;
              gitName = inputs.identity.gitName;
              home = "/Users/${inputs.identity.darwinName}";
            };
            isDarwin = true;
            lib = nixpkgs.lib.extend (self: super: (import ./lib/default.nix { lib = self; }));
          };
          modules = [
            ({ ... }: {
              nixpkgs.overlays = [
                (final: prev: {
                  # TODO: Remove direnv override once macOS/Sandbox hangs are resolved upstream
                  direnv = prev.direnv.overrideAttrs (old: { doCheck = false; });
                })
              ];
            })
            ./modules/default.nix
            ./hosts/stellyrtop/default.nix
            mac-app-util.darwinModules.default
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; identity = { name = inputs.identity.darwinName; email = inputs.identity.userEmail; gitName = inputs.identity.gitName; home = "/Users/${inputs.identity.darwinName}"; }; };
                backupFileExtension = "backup";
                overwriteBackup = true;
              };
            }
          ];
        };
      };
    };
}
