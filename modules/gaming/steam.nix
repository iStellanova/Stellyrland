{ inputs, ... }: {
  flake-file.inputs.chaotic = {
    url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake.modules.nixos.steam = { pkgs, ... }: {
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
        libcap
        gamescope-wsi
      ];
      extraCompatPackages = with pkgs; [
        proton-ge-bin
        proton-cachyos
      ];
    };
  };

  flake.modules.darwin.steam = _: {
    homebrew.casks = [ "steam" ];
  };
}
