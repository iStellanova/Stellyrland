{
  config,
  lib,
  ...
}: let
  cfg = config.aspects.core.headless;
in {
  options.aspects.core.headless = {
    enable = lib.mkEnableOption "Headless/Remote-only specialisation";
    disabledPorts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = lib.attrNames config.aspects.core.monitors;
      description = "Display ports to disable in the headless specialisation.";
    };
  };

  config = lib.mkIf cfg.enable {
    specialisation.headless.configuration = {
      # 1. Disable GUI-heavy aspects.
      aspects.desktop.hyprland.enable = lib.mkForce false;
      aspects.desktop.styling.enable = lib.mkForce false;
      aspects.services.desktop-services.enable = lib.mkForce false;

      # 2. Disable login manager (no GUI, no Hyprland to hand off to).
      aspects.services.greetd.enable = lib.mkForce false;

      # 3. Disable heavy GUI-only programs to save resources.
      aspects.programs = {
        media.enable = lib.mkForce false;
        browser.enable = lib.mkForce false;
        gaming.enable = lib.mkForce false;
        vesktop.enable = lib.mkForce false;
        zed.enable = lib.mkForce false;
        noctalia-shell.enable = lib.mkForce false;
        antigravity.enable = lib.mkForce false;
        cava.enable = lib.mkForce false;
        gsr.enable = lib.mkForce false;
        kitty.enable = lib.mkForce false;
        aesthetic.enable = lib.mkForce false;
      };

      # 4. Hardware specific: Disable display outputs.
      boot.kernelParams = map (port: "video=${port}:d") cfg.disabledPorts;

      # 5. QOL: Custom TTY greeting for confirmation.
      services.getty.greetingLine = lib.mkForce "Welcome to Stellyrland (Headless/Remote Mode)";
    };
  };
}
