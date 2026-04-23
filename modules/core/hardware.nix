{ config, lib, ... }:

{
  options.aspects.core.hardware.enable = lib.mkEnableOption "Core hardware settings" // { default = true; };

  config = lib.mkIf config.aspects.core.hardware.enable {
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = true;

    # ZRAM Swap
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
    };

    # SSD Maintenance
    services.fstrim.enable = true;

    # Enable Sched-ext (scx) support
    services.scx.enable = true;
    services.scx.scheduler = "scx_lavd";
  };
}
