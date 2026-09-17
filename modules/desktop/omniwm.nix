{
  modules.darwin.omniwm = {
    homebrew.taps = [ "BarutSRB/tap" ];
    homebrew.casks = [ "BarutSRB/tap/omniwm" ];
    nix-homebrew.trust.casks = [ "BarutSRB/tap/omniwm" ];
  };
}
