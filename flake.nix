{
  description = "Stellyrland Configurations";

  # This flake serves as the single entry point for all systems (Linux and macOS).
  # It leverages flake-parts for clean attribute separation and a custom recursive
  # module scanner in lib/ for automated feature discovery.

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # TODO: Remove this pin once deno/rusty-v8 build issues are resolved
    nixpkgs-deno.url = "github:nixos/nixpkgs/3e2cf88148e732abc1d259286123e06a9d8c964a";

    # Home Manager.
    home-manager = {
      url = "github:nix-community/home-manager";
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
      url = "github:linusammon/noctalia-shell/v5-hm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Darwin.
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Mac App Util.
    mac-app-util.url = "github:hraban/mac-app-util";

    # Identity from private repo.
    identity.url = "git+ssh://git@github.com/iStellanova/stellyrdentity.git";

    # Hyprland.
    hyprland.url = "github:hyprwm/Hyprland";

    # Split Monitor Workspaces plugin.
    split-monitor-workspaces = {
      url = "github:zjeffer/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    # Echo AI Personality Forge.
    echo.url = "git+ssh://git@github.com/iStellanova/Project-Echo.git";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = [
        ./flake/lib.nix
        ./flake/hosts.nix
      ];
    };
}
