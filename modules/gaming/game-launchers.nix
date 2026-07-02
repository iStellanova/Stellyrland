{ sn, ... }: {
  sn.gaming = {
    includes = [ sn.game-launchers ];
  };

  sn.game-launchers.nixos = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      mangohud
      goverlay
      prismlauncher
      protonplus
      r2modman
    ];
  };

  sn.game-launchers.darwin = _: {
    homebrew.casks = [ "prismlauncher" ];
  };
}
