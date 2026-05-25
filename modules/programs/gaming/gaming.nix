_: {
  # NixOS Gaming Settings
  flake.modules.nixos.gaming = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.aspects.programs.gaming.enable = lib.mkEnableOption "Gaming suite (Steam, Gamemode, etc.)";

    config = lib.mkIf config.aspects.programs.gaming.enable {
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
  flake.modules.darwin.gaming = {
    config,
    lib,
    ...
  }: {
    options.aspects.programs.gaming.enable = lib.mkEnableOption "Gaming suite (Steam, Gamemode, etc.)";

    config = lib.mkIf config.aspects.programs.gaming.enable {
      homebrew.casks = ["steam" "prismlauncher"];
    };
  };
}
