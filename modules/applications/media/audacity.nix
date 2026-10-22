{
  modules.nixos.audacity = { pkgs, ... }: {
    # TODO: Switch to audacity_4 once pinned nixpkgs includes this fix and its output is cached:
    # https://github.com/NixOS/nixpkgs/pull/577022
    environment.systemPackages = [ pkgs.audacity_3 ];
  };

  modules.darwin.audacity = {
    homebrew.casks = [ "audacity" ];
  };
}
