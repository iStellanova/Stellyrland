{
  inputs,
  config,
  ...
}: let
  mkHost = {
    system,
    isDarwin,
    hostname,
    extraModules ? [],
  }: let
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
      modules =
        [
          # Consolidate and load Dendritic features compiled at the flake level
          (
            if isDarwin
            then config.flake.modules.darwin.default
            else config.flake.modules.nixos.default
          )

          ../hosts/${hostname}/default.nix
          hmModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
              sharedModules = [
                # Pure dendritic Home Manager configurations
                config.flake.modules.homeManager.default

                inputs.catppuccin.homeModules.catppuccin
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
    # Export consolidated dendritic module interfaces
    nixosModules.default = config.flake.modules.nixos.default;
    darwinModules.default = config.flake.modules.darwin.default;
    homeManagerModules.default = config.flake.modules.homeManager.default;

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
        inputs.sops-nix.nixosModules.sops
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
