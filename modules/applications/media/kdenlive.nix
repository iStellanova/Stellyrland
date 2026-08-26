{
  flake.modules.finix.kdenlive = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.kdePackages.kdenlive ];
  };

  flake.modules.nixos.kdenlive = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.kdePackages.kdenlive ];
  };
}
