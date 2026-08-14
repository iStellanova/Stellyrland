_: {
  flake.modules.nixos.nautilus =
    {
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        nautilus
        sushi
        evince
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ];

      environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
          (
            with pkgs.gst_all_1;
            [
              gstreamer
              gst-plugins-base
              gst-plugins-good
              gst-plugins-bad
              gst-plugins-ugly
              gst-libav
            ]
          );

      services.gnome.tinysparql.enable = true;
      services.gnome.localsearch.enable = true;

      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/nautilus/preferences" = {
            default-folder-viewer = "list-view";
            # Prevents nautilus from clobbering the GTK4 key on first run
            migrated-gtk-settings = true;
          };
          # nautilus 50+: show-hidden moved here; old show-hidden-files key is ignored
          settings."org/gtk/gtk4/settings/file-chooser" = {
            show-hidden = true;
          };
          settings."org/gnome/desktop/interface" = {
            clock-format = "12h";
          };
        }
      ];
    };

  flake.modules.homeManager.nautilus =
    {
      host,
      pkgs,
      lib,
      ...
    }:
    {
      home.file.".config/gtk-3.0/bookmarks" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        text = ''
          file://${host.homeDir}/Downloads
          file://${host.homeDir}/Pictures
          file://${host.homeDir}/Videos
          file://${host.homeDir}/Documents
          file://${host.homeDir}/Music
          file://${host.homeDir}/Projects
          file://${host.flakePath}
        '';
      };
    };
}
