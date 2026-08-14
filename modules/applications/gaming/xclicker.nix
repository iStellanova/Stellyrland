_: {
  flake.modules.nixos.xclicker = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.xclicker ];
  };
}
