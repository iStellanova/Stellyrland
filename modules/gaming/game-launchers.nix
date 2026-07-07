{ sn, ... }: {
  sn.gaming = {
    includes = [ sn.game-launchers ];
  };

  sn.game-launchers.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      mangohud
      goverlay
      protonplus
      r2modman
    ];
  };

  sn.game-launchers.os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      prismlauncher
    ];
  };
}
