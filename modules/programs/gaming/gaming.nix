_: {
  # NixOS Gaming Settings
  flake.modules.nixos.gaming = {pkgs, ...}: {
    config = {
      programs.gamemode.enable = true;
      programs.steam = {
        enable = true;
        extraPackages = with pkgs; [
          libcap
        ];
      };
      programs.gamescope.enable = true;

      environment.systemPackages = with pkgs; [
        heroic
        prismlauncher
        protonplus
        r2modman
      ];
    };
  };

  # Darwin Gaming Settings
  flake.modules.darwin.gaming = _: {
    config = {
      homebrew.casks = ["steam" "prismlauncher"];
    };
  };
}
