{
  self,
  inputs,
  ...
}: let
  mkHost = {
    system,
    isDarwin,
    hostname,
    extraModules ? [],
  }: let
    identity = self.lib.mkIdentity inputs.stellyrdata isDarwin;
    coreBuilder =
      if isDarwin
      then inputs.nix-darwin.lib.darwinSystem
      else inputs.nixpkgs.lib.nixosSystem;
    hmModule =
      if isDarwin
      then inputs.home-manager.darwinModules.home-manager
      else inputs.home-manager.nixosModules.home-manager;
  in
    coreBuilder {
      inherit system;
      specialArgs = {
        inherit inputs;
        inherit (self) lib;
        inherit identity isDarwin;
      };
      modules =
        [
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
              sharedModules = [
                inputs.nix-index-database.homeModules.nix-index
                inputs.nixvim.homeModules.nixvim
              ];
            };
          }
        ]
        ++ extraModules;
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
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.lanzaboote.nixosModules.lanzaboote
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
