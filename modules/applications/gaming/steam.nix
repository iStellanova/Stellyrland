{ inputs, ... }: {
  flake-file.inputs.chaotic = {
    url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # For Steam game HDR:
  # PROTON_ENABLE_WAYLAND=1 PROTON_USE_NTSYNC=1 RADV_PERFTEST=gpl %command%
  # Use CachyOS's Proton.
  flake.modules.nixos.steam =
    {
      lib,
      pkgs,
      host,
      ...
    }:
    {
      nixpkgs.overlays = [ inputs.chaotic.overlays.default ];
      boot.kernelModules = [ "ntsync" ];
      boot.kernel.sysctl = {
        "vm.max_map_count" = 2147483642;
      };

      programs.gamemode.enable = true;
      programs.steam = {
        enable = true;
        localNetworkGameTransfers.openFirewall = true;
        extraPackages = with pkgs; [
          gamescope-wsi
        ];
        extraCompatPackages = with pkgs; [
          proton-ge-bin
          proton-cachyos
        ];
      };

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/share/Steam"
          ".steam"
        ];
      };
    };

  flake.modules.darwin.steam = {
    homebrew.casks = [ "steam" ];
  };
}
