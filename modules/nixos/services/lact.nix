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
          temperature_key = "junction";
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
        power_cap = 402.0;
        performance_level = "manual";
        min_core_clock = 2700;
        max_core_clock = 3000;
        max_memory_clock = 1350;
        voltage_offset = -20;
        power_profile_mode_index = 0;
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
              temperature_key = "junction";
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
            power_cap = 402.0;
            performance_level = "manual";
            min_core_clock = 2700;
            max_core_clock = 3000;
            max_memory_clock = 1350;
            voltage_offset = -20;
            power_profile_mode_index = 0;
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
