{ config, lib, pkgs, identity, isDarwin, ... }:

{
  options.aspects.programs.vesktop.enable = lib.mkEnableOption "Vesktop Discord client";

  config = lib.mkIf config.aspects.programs.vesktop.enable (lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      homebrew.casks = [ "discord" ];
    })

    (lib.optionalAttrs (!isDarwin) {
      environment.systemPackages = [
        (pkgs.vesktop.override { withSystemVencord = false; })
      ];
    })

    {
      home-manager.users.${identity.name} = {
        # Vesktop configuration
        xdg.configFile."vesktop/settings.json".text = builtins.toJSON {
          discordBranch = "stable";
          minimizeToTray = true;
          arRPC = true;
          splashColor = "rgb(202, 211, 245)";
          splashBackground = "rgb(24, 25, 38)";
        };
      };
    }
  ]);
}
