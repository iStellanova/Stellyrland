{sn, ...}: {
  sn.av = {includes = [sn.music];};

  sn.music.nixos = {config, ...}: {
    services.mpdscribble = {
      enable = true;
      endpoints."last.fm" = {
        username = "iFazwolf";
        passwordFile = config.sops.secrets.lastfm-password.path;
      };
    };
  };

  sn.music.homeManager = {
    pkgs,
    host,
    ...
  }: {
    home.packages = with pkgs; [mpc rmpc];

    services.mpd = {
      enable = true;
      musicDirectory = "${host.homeDir}/Music";
      network.listenAddress = "${host.homeDir}/.local/share/mpd/socket";
      extraConfig = ''
        bind_to_address "127.0.0.1"
        audio_output {
          type "pipewire"
          name "PipeWire Sound Server"
        }
        audio_output {
          type "fifo"
          name "Visualizer"
          path "/tmp/mpd.fifo"
          format "44100:16:2"
        }
      '';
    };

    xdg.configFile."rmpc/config.ron".text =
      import ./_config.nix {inherit (host) homeDir;};

    services.mpdris2.enable = true;

    systemd.user.services.mpdris2.Unit.After = ["mpd.service"];
  };
}
