{ config, lib, pkgs, ... }:

let
  cfg = config.aspects.services.lact;
  configData = {
    version = 5;
    daemon = {
      log_level = "info";
      admin_group = "wheel";
      disable_clocks_cleanup = false;
    };
    apply_settings_timer = 5;
    gpus = {
      "1002:744C-1EAE:7901-0000:03:00.0" = {
        fan_control_enabled = true;
        fan_control_settings = {
          mode = "curve";
          static_speed = 0.0;
          temperature_key = "junction"; # Use junction temperature for fan control.
          interval_ms = 500;
          curve = {
            "40" = 0.15;
            "50" = 0.3;
            "60" = 0.5;
            "70" = 0.8;
            "75" = 1.0;
          };
        };
        pmfw_options = {
          zero_rpm = true;
        };
        power_cap = 402.0; # Increased power cap to 402W for higher boost headroom.
        performance_level = "manual";
        min_core_clock = 2700; # High minimum clock to prevent stutter during frequency switching.
        max_core_clock = 3000; # Mild overclock for better peak performance.
        max_memory_clock = 1350; # Aggressive memory overclock.
        voltage_offset = -20; # Undervolted to reduce heat and power consumption while maintaining stability.
        power_profile_mode_index = 0; # Use the high-performance power profile.
      };
    };
    profiles = {
      default = {
        gpus = {
          "1002:744C-1EAE:7901-0000:03:00.0" = {
            fan_control_enabled = true;
            fan_control_settings = {
              mode = "curve";
              static_speed = 0.0;
              temperature_key = "junction"; # Use junction temperature for fan control.
              interval_ms = 500;
              curve = {
                "40" = 0.15;
                "50" = 0.3;
                "60" = 0.5;
                "70" = 0.8;
                "75" = 1.0;
              };
            };
            pmfw_options = {
              zero_rpm = true;
            };
            power_cap = 402.0; # Cap power to 402W.
            performance_level = "manual";
            min_core_clock = 2700; # Higher to avoid spikes.
            max_core_clock = 3000; # Overclocked.
            max_memory_clock = 1350; # Overclocked.
            voltage_offset = -20; # Undervolted for better efficiency.
            power_profile_mode_index = 0; # Use performance mode.
          };
        };
      };
    };
    current_profile = "default";
    auto_switch_profiles = false;
  };
  yamlFile = (pkgs.formats.yaml {}).generate "lact-config.yaml" configData;
  lactConfig = pkgs.runCommand "lact-config.yaml" {} ''
    sed "s/'\([0-9]*\)':/\1:/g" ${yamlFile} > $out
  '';
in
{
  options.aspects.services.lact.enable = lib.mkEnableOption "LACT GPU tuning service";

  config = lib.mkIf cfg.enable {
    # Enable the LACT daemon
    services.lact.enable = true;

    # Manage the configuration file with GPU tuning
    environment.etc."lact/config.yaml".source = lactConfig;
  };
}
