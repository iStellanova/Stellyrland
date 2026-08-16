{
  flake.modules.nixos.soulseek = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.nicotine-plus ];
  };

  flake.modules.darwin.soulseek = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.nicotine-plus ];
  };
}
