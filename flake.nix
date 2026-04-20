{
  description = "Modular NixOS configuration for stellyrland";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:youwen5/zen-browser-flake";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-nix-monitor = {
      url = "github:caesar-admin/Noctalia-Nix-Monitor";
      flake = false;
    };

    noctalia-plugins = {
      url = "github:noctalia-dev/noctalia-plugins";
      flake = false;
    };

    qs-hyprview-src = {
      url = "github:dom0/qs-hyprview";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-cachyos-kernel, noctalia-shell, noctalia-nix-monitor, noctalia-plugins, qs-hyprview-src, ... }@inputs: {
    nixosConfigurations.stellyrland = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/stellyrland/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.stellanova = import ./hosts/stellyrland/home.nix;
            backupFileExtension = "backup";
            overwriteBackup = true;
          };
        }
      ];
    };
  };
}
