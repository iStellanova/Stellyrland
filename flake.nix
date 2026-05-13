{
  description = "Stellyrland - A Modular, Dendritic NixOS and Darwin configuration";

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
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia Nix Monitor.
    noctalia-nix-monitor = {
      url = "github:iStellanova/Nix-Monitor";
      flake = false;
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
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.aquamarine.follows = "aquamarine";
    };

    # Aquamarine rendering backend.
    # Pinned to be35f75 which fixes uninitialised CTM causing black screens
    # with Hyprland 0.55 colour management (sdrbrightness/sdrsaturation).
    # Ref: https://github.com/hyprwm/aquamarine/commit/be35f75
    #
    #
    # TODO: Unpin aquamarine when Hyprland's own bundled aquamarine advances
    #   past be35f75 on its own — the pin is redundant at that point.
    #   Check after any hyprland flake bump:
    #     nix flake metadata /etc/nixos | grep -A2 aquamarine
    #   If the rev shown is be35f75 or later, remove:
    #     1. The entire `aquamarine` input block below.
    #     2. `inputs.aquamarine.follows` from the `hyprland` input above
    #        (revert to plain `hyprland.url = "github:hyprwm/Hyprland";`).
    #     3. Run `nix flake lock --update-input hyprland` to clean the lock.
    #   Re-enable `bitdepth, 10` in modules/common/core/monitors.nix
    #   separately — that is an AMD amdgpu/DRM atomic commit issue with the
    #   XRGB2101010 format, unrelated to CTM. Test after a kernel upgrade.
    aquamarine = {
      url = "github:hyprwm/aquamarine/be35f75ac305f430f5f9d89b5f5a4af59ca7567e";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Split Monitor Workspaces plugin.
    split-monitor-workspaces = {
      url = "github:zjeffer/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
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
