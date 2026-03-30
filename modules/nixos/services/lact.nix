{ config, pkgs, lib, ... }:

{
  # Enable the LACT daemon
  services.lact.enable = true;

  # DISABLE Overdrive (Overclocking/Undervolting) to prevent SMU crashes
  hardware.amdgpu.overdrive.enable = false;

  # Manage the configuration file with NO GPU tuning
  environment.etc."lact/config.yaml".text = (lib.generators.toYAML {} {
    version = 5;
    daemon = {
      log_level = "info";
      admin_group = "wheel";
      disable_clocks_cleanup = false;
    };
    apply_settings_timer = 5;
    gpus = {};
    profiles = {
      default = {
        gpus = {};
      };
    };
    current_profile = null;
    auto_switch_profiles = false;
  });
}
