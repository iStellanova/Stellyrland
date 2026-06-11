{
  sn,
  ...
}: {
  sn.gaming = {includes = [sn.steam];};

  sn.steam.nixos = {pkgs, ...}: {
    boot.kernelModules = ["ntsync"];
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      "kernel.nmi_watchdog" = 0;
    };

    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = with pkgs; [libcap gamescope-wsi];
    };
  };

  sn.steam.darwin = _: {
    homebrew.casks = ["steam"];
  };
}
