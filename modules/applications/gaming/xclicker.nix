{
  flake.modules.finix.xclicker = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xclicker ];
  };

  flake.modules.nixos.xclicker = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xclicker ];
  };
}
