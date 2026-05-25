_: {
  # NixOS Media Settings
  flake.modules.nixos.media = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.aspects.programs.media.enable = lib.mkEnableOption "Media players and consumption tools";

    config = lib.mkIf config.aspects.programs.media.enable {
      environment.systemPackages = with pkgs; [
        ffmpegthumbnailer
        imv
        lollypop
        pavucontrol
      ];
    };
  };

  # Darwin Media Settings
  flake.modules.darwin.media = {
    config,
    lib,
    ...
  }: {
    options.aspects.programs.media.enable = lib.mkEnableOption "Media players and consumption tools";

    config = lib.mkIf config.aspects.programs.media.enable {
      homebrew.casks = [
        "background-music"
        "vlc"
      ];
    };
  };

  # Home Manager Media Settings
  flake.modules.homeManager.media = {
    osConfig,
    pkgs,
    lib,
    ...
  }: let
    isDarwin = osConfig ? system.defaults;
  in
    lib.mkIf (osConfig ? aspects.programs.media && osConfig.aspects.programs.media.enable) {
      home.packages = with pkgs;
        [ani-cli ffmpeg mpv]
        ++ lib.optionals (!isDarwin) [nicotine-plus];
    };
}
