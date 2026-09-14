{
  modules.nixos.audacity = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.audacity ];
  };

  modules.darwin.audacity = {
    homebrew.casks = [ "audacity" ];
  };
}
