{ config, lib, pkgs, ... }:

{
  options.aspects.programs.media.enable = lib.mkEnableOption "Multimedia applications";

  config = lib.mkIf config.aspects.programs.media.enable {
    environment.systemPackages = with pkgs; [
      ani-cli                  # A cli tool to browse and watch anime
      blanket                  # Listen to different sounds to improve focus
      davinci-resolve          # Professional video editing
      ffmpeg                   # Cross-platform solution to record, convert and stream audio and video
      ffmpegthumbnailer        # A lightweight video thumbnailer
      imv                      # A command line image viewer
      losslesscut-bin          # Lossless video editing
      lollypop                 # A modern music player for GNOME
      mpv                      # A free, open source, and cross-platform media player
      mprisence                # Discord Rich Presence for MPRIS
      nicotine-plus            # A graphical client for Soulseek
      obs-studio               # Free and open source software for video recording
      parabolic                # A fast and simple video downloader
      pavucontrol              # PulseAudio Volume Control
    ];
  };
}
