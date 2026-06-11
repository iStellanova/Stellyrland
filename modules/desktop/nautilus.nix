{sn, ...}: {
  sn.desktop = {includes = [sn.nautilus];};

  sn.nautilus.nixos = {
    pkgs,
    lib,
    ...
  }: {
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

    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);

    services.gnome.tinysparql.enable = true;
    services.gnome.localsearch.enable = true;

    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          # Tell nautilus migration already ran so it doesn't clobber the GTK4 key below
          migrated-gtk-settings = true;
        };
        # nautilus 50+ reads show-hidden from here; the old show-hidden-files key is deprecated/ignored
        settings."org/gtk/gtk4/settings/file-chooser" = {
          show-hidden = true;
        };
      }
    ];
  };

  sn.nautilus.homeManager = {
    host,
    pkgs,
    lib,
    ...
  }: {
    home.file.".config/gtk-3.0/bookmarks" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      text = ''
        file://${host.homeDir}/Downloads
        file://${host.homeDir}/Pictures
        file://${host.homeDir}/Videos
        file://${host.homeDir}/Documents
        file://${host.homeDir}/Music
        file://${host.homeDir}/Projects
        file://${host.homeDir}/Projects/stellyrland
      '';
    };
  };
}
