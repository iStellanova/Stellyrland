{
  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    log-lines = 25;
    auto-optimise-store = true;
    warn-dirty = false;
    min-free = 2147483648; # 2GB
    max-free = 5368709120; # 5GB
    builders-use-substitutes = true;
  };

  # NH cleaner
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 5";
    flake = "/etc/nixos";
  };

  environment.variables = {
    FLAKE = "/etc/nixos";
    NIXOS_OZONE_WL = "1";
  };

  nixpkgs.config.allowUnfree = true;
}
