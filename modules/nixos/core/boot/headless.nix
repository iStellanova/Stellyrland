{ config, lib, ... }:

let
  cfg = config.aspects.core.headless;
in
{
  options.aspects.core.headless = {
    enable = lib.mkEnableOption "Headless/Remote-only specialisation";
    disabledPorts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of display ports to disable (kernel level) in headless mode (e.g. ['DP-2', 'DP-3']).";
    };
  };

  config = lib.mkIf cfg.enable {
    specialisation.headless.configuration = {
      # 1. Disable GUI-heavy aspects.
      aspects.desktop.hyprland.enable = lib.mkForce false;
      aspects.desktop.styling.enable = lib.mkForce false;
      aspects.services.desktop-services.enable = lib.mkForce false;

      # 2. Disable heavy GUI-only programs to save resources.
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
        fastfetch.enable = lib.mkForce false;
      };

      # 3. Hardware specific: Disable display outputs.
      boot.kernelParams = map (port: "video=${port}:d") cfg.disabledPorts;

      # 4. QOL: Custom TTY greeting for confirmation.
      services.getty.greetingLine = lib.mkForce "Welcome to Stellyrland (Headless/Remote Mode)";
    };
  };
}
