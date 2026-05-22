{
  inputs,
  config,
  lib,
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
        (
          if isDarwin
          then lib.attrValues config.flake.modules.darwin
          else lib.attrValues config.flake.modules.nixos
        )
        ++ [
          ../hosts/${hostname}/default.nix
          hmModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              overwriteBackup = true;
              sharedModules =
                (lib.attrValues config.flake.modules.homeManager)
                ++ [
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
    nixosModules.default = {imports = lib.attrValues config.flake.modules.nixos;};
    darwinModules.default = {imports = lib.attrValues config.flake.modules.darwin;};
    homeManagerModules.default = {imports = lib.attrValues config.flake.modules.homeManager;};

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
