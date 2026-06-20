{sn, ...}: {
  sn.av = {host, ...}: {
    includes =
      if host.class == "nixos"
      then [sn.gsr]
      else [];
  };

  sn.gsr.nixos = {pkgs, ...}: {
    programs.gpu-screen-recorder.enable = true;
    environment.systemPackages = [pkgs.gpu-screen-recorder-gtk];
  };

  sn.gsr.homeManager = {
    host,
    pkgs,
    ...
  }: {
    xdg.configFile."gpu-screen-recorder/config".text = ''
      main.advanced_view false
      main.audio_codec opus
      main.audio_input device:Default output
      main.av1_amd_bug_warning_shown false
      main.change_video_resolution false
      main.codec av1
      main.color_range full
      main.fps 60
      main.framerate_mode auto
      main.hevc_amd_bug_warning_shown false
      main.hide_window_when_recording false
      main.installed_gsr_global_hotkeys_version 0
      main.merge_audio_tracks true
      main.overclock false
      main.quality very_high
      main.record_app_audio_inverted false
      main.record_area_height 1080
      main.record_area_option portal
      main.record_area_width 1920
      main.record_cursor true
      main.restore_portal_session true
      main.show_recording_saved_notifications true
      main.show_recording_started_notifications false
      main.show_recording_stopped_notifications false
      main.software_encoding_warning_shown false
      main.steam_deck_warning_shown false
      main.use_new_ui false
      main.video_bitrate 15000
      main.video_height 1080
      main.video_width 1920
      record.container mp4
      record.pause_unpause_recording_hotkey 0 0
      record.save_directory ${host.homeDir}/Videos/gsr/
      record.start_stop_recording_hotkey 0 0
      replay.container mp4
      replay.save_directory ${host.homeDir}/Videos/gsr/
      replay.save_recording_hotkey 0 0
      replay.start_stop_recording_hotkey 0 0
      replay.time 30
      streaming.custom.container flv
      streaming.custom.url
      streaming.service twitch
      streaming.start_stop_recording_hotkey 0 0
      streaming.twitch.key
      streaming.youtube.key
    '';

    systemd.user.services.gsr-replay = {
      Unit = {
        Description = "GPU Screen Recorder – continuous replay buffer";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/Videos/Replays";
        ExecStart = builtins.concatStringsSep " " [
          "${pkgs.gpu-screen-recorder}/bin/gpu-screen-recorder"
          "-w DP-2"
          "-r 120"
          "-c mp4"
          "-k av1_hdr"
          "-q very_high"
          "-ac opus"
          "-a default_output|default_input"
          "-cr full"
          "-f 60"
          "-cursor yes"
          "-o %h/Videos/Replays"
          "-ro %h/Videos/Replays"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
