_: {
  flake.modules.nixos.davinci-resolve = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.davinci-resolve ];
  };
}
