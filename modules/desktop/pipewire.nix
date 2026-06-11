{
  sn,
  ...
}: {
  sn.desktop = {includes = [sn.pipewire];};

  sn.pipewire.nixos = _: {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      extraConfig = {
        pipewire."99-lowlatency" = {
          "context.properties"."default.clock.min-quantum" = 512;
          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              flags = ["ifexists" "nofail"];
              args = {
                "nice.level" = -15;
                "rt.prio" = 88;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
            }
          ];
        };
        pipewire-pulse."99-lowlatency" = {
          "pulse.properties" = {
            "server.address" = ["unix:native"];
            "pulse.min.req" = "512/48000";
            "pulse.min.quantum" = "512/48000";
            "pulse.min.frag" = "512/48000";
            "pulse.flat-volumes" = false;
          };
        };
        client."99-lowlatency"."stream.properties" = {
          "node.latency" = "512/48000";
          "resample.quality" = 4;
        };
      };
      wireplumber = {
        enable = true;
        extraConfig = {
          "10-ignore-vols" = {
            "monitor.alsa.rules" = [
              {
                matches = [{"media.class" = "Audio/Source";}];
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
