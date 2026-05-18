{
  config,
  lib,
  pkgs,
  ...
}:
# Aggressive overclock to get the most out of my GPU.
# Manually tuned for maximum performance.
let
  cfg = config.aspects.services.lact;
  gpuConfig = {
    fan_control_enabled = true;
    fan_control_settings = {
      mode = "curve";
      static_speed = 0.0;
      temperature_key = "junction"; # Use junction temperature for fan control.
      interval_ms = 500;
      curve = {
        "45" = 0.20;
        "60" = 0.40;
        "80" = 0.65;
        "90" = 0.85;
        "100" = 1.0;
      };
    };
    pmfw_options = {
      zero_rpm = true;
    };
    power_cap = 402.0; # +15% power limit.
    performance_level = "manual";
    min_core_clock = 2700; # High minimum to avoid sudden dips during load.
    max_core_clock = 3000;
    max_memory_clock = 1250; # Kept at 1250, as 1350 cause white static lines.
    voltage_offset = -20;
    power_profile_mode_index = 0;
  };
  configData = {
    version = 5;
    daemon = {
      log_level = "info";
      admin_group = "wheel";
      disable_clocks_cleanup = true;
    };
    apply_settings_timer = 5;
    gpus = {
      "1002:744C-1EAE:7901-0000:03:00.0" = gpuConfig;
    };
    profiles = {
      default = {
        gpus = {
          "1002:744C-1EAE:7901-0000:03:00.0" = gpuConfig;
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
in {
  options.aspects.services.lact.enable = lib.mkEnableOption "LACT GPU tuning service";

  config = lib.mkIf cfg.enable {
    # Enable the LACT daemon
    services.lact.enable = true;

    # Manage the configuration file with GPU tuning
    environment.etc."lact/config.yaml".source = lactConfig;
  };
}
