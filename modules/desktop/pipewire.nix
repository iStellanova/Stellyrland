_: {
  flake.modules.nixos.pipewire = _: {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      wireplumber = {
        enable = true;
        extraConfig = {
          "10-ignore-vols" = {
            "monitor.alsa.rules" = [
              {
                matches = [ { "media.class" = "Audio/Source"; } ];
                actions = {
                  update-props = {
                    "node.ignore-session-volume" = true;
                  };
                };
              }
            ];
          };
        };
      };
    };
  };
}
