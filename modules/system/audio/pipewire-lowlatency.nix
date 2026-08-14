_: {
  flake.modules.nixos.pipewire-lowlatency = _: {
    services.pipewire.extraConfig = {
      pipewire."99-lowlatency" = {
        "context.properties"."default.clock.min-quantum" = 512;
        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            flags = [
              "ifexists"
              "nofail"
            ];
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
          "server.address" = [ "unix:native" ];
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
  };
}
