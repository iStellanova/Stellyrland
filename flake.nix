{
  description = "Stellyrland Configurations";

  # This flake serves as the single entry point for all systems (Linux and macOS).
  # It leverages flake-parts for modular output composition, import-tree for
  # automated module discovery, and Den for aspect-oriented configuration.

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake Parts - modular flake output composition.
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Den - aspect-oriented, context-aware Nix configuration framework.
    den.url = "github:denful/den";

    # Import Tree - recursive module scanner (replaces lib/scan).
    import-tree.url = "github:vic/import-tree";

    # Home Manager.
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS kernel.
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Zen Browser.
    zen-browser.url = "github:youwen5/zen-browser-flake";

    # Catppuccin theming.
    catppuccin.url = "github:catppuccin/nix";

    # Nix Software Center - GUI package manager.
    nix-software-center = {
      url = "github:snowfallorg/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia shell.
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin.
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mac App Util.
    mac-app-util.url = "github:hraban/mac-app-util";

    # Hyprland.
    # TODO: unpin once hyprland flake fixes missing MonitorZoomController.hpp in dev headers
    # (0aa7a84 introduced the file but doesn't install it, breaking split-monitor-workspaces)
    hyprland.url = "github:hyprwm/Hyprland/367beccd27df394461cc80ba845d0088b5f87690";

    # Split Monitor Workspaces plugin.
    split-monitor-workspaces = {
      url = "github:zjeffer/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    # nix-index pre-built database + comma.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Treefmt - unified code formatter orchestration.
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lanzaboote - Secure Boot for NixOS via signed UKIs.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Preservation - declarative opt-in persistence via native systemd units.
    preservation.url = "github:nix-community/preservation";

    # Sops-Nix - secure secrets management using age.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Flatpak - declarative Flatpak package management.
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Custom assets and wallpapers.
    my-assets = {
      url = "github:iStellanova/Stellyrland/assets";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
