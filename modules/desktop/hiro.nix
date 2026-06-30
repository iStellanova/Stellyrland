{sn, ...}: {
  sn.desktop = {host, ...}: {
    includes =
      if host.class == "darwin"
      then [sn.hiro]
      else [];
  };

  sn.hiro.darwin = _: {
    homebrew.taps = ["BarutSRB/tap"];
    homebrew.casks = ["BarutSRB/tap/omniwm"];
  };
}
