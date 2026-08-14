_: {
  flake.modules.nixos.pipewire =
    {
      lib,
      host,
      ...
    }:
    {

      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        wireplumber = {
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

      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [
          ".local/state/wireplumber"
        ];
      };

    };
}
