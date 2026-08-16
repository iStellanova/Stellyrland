{
  flake.modules.nixos.audacity = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.audacity ];
  };

  flake.modules.darwin.audacity = {
    homebrew.casks = [ "audacity" ];
  };
}
