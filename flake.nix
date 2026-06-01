{
  description = "Stellyrland Configurations";

  # This flake serves as the single entry point for all systems (Linux and macOS).
  # It leverages flake-parts for clean attribute separation and a custom recursive
  # module scanner in lib/ for automated feature discovery.

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake Parts - modular flake output composition.
    flake-parts.url = "github:hercules-ci/flake-parts";
    # TODO: Remove this pin once deno/rusty-v8 build issues are resolved
    nixpkgs-deno.url = "github:nixos/nixpkgs/3e2cf88148e732abc1d259286123e06a9d8c964a";

    # Home Manager.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS kernel.
    cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Zen Browser.
    zen-browser.url = "github:youwen5/zen-browser-flake";

    # Catppuccin theming.
    catppuccin.url = "github:catppuccin/nix";

    # Noctalia shell.
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell/v5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pyproject.nix + uv2nix + build-system-pkgs — PEP 517 / uv.lock packaging for Nix.
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };

    # Letta source — agent framework with stateful memory (built via uv2nix).
    # check-update: https://github.com/letta-ai/letta/releases
    letta-src = {
      url = "github:letta-ai/letta";
      flake = false;
    };

    # Nix Darwin.
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mac App Util.
    mac-app-util.url = "github:hraban/mac-app-util";

    # Hyprland.
    hyprland.url = "github:hyprwm/Hyprland";

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

    # NixVim - Neovim configuration system for Nix.
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
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

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({lib, ...}: {
      imports =
        # flakeModules.modules must be declared at this level — flake-parts does not
        # recursively process it when it arrives via a scanned module's imports.
        [inputs.flake-parts.flakeModules.modules]
        ++ (import ./lib/default.nix {inherit lib;}).scan ./modules;
    });
}
