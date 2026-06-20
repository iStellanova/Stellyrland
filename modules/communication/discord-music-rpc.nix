{sn, ...}: {
  sn.communication = {includes = [sn.discord-music-rpc];};

  sn.discord-music-rpc.darwin = _: {
    homebrew.taps = ["nextfire/tap"];
    homebrew.brews = ["apple-music-discord-rpc"];
  };
}
