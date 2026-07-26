_: {
  flake.modules.nixos.audacity = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.audacity ];
  };
}
