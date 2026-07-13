_: {
  flake.modules.nixos.steam = { pkgs, ... }: {
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
    };
  };

  flake.modules.darwin.steam = _: {
    homebrew.casks = [ "steam" ];
  };
}
