_: {
  flake.modules.nixos.headless =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.core.headless;
    in
    {
      options.core.headless.disabledPorts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Display ports to disable in the headless specialisation.";
      };

      config = {
        specialisation.headless.configuration = {
          boot.kernelParams = map (port: "video=${port}:d") cfg.disabledPorts;
          services.getty.greetingLine = lib.mkForce "Welcome to ${config.networking.hostName} (Headless/Remote Mode)";
        };

        # Sets the 'headless'/GUI specialisation as the default boot entry and reboots.
        environment.shellAliases = {
          reboot-headless = "sudo /run/current-system/specialisation/headless/bin/switch-to-configuration boot && sudo reboot";
          reboot-gui = "sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot && sudo reboot";
        };
      };
    };
}
