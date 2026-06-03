_: {
  flake.modules.homeManager.nautilus = {osConfig, ...}: {
    dconf.settings."org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = true;
    };

    home.file.".config/gtk-3.0/bookmarks".text = let
      home = osConfig.identity.homeDir;
    in ''
      file://${home}/Documents
      file://${home}/Pictures
      file://${home}/Music
      file://${home}/Videos
      file://${home}/Projects
      file://${home}/Projects/stellyrland
    '';
  };

  # NixOS Nautilus Settings
  flake.modules.nixos.nautilus = {
    pkgs,
    lib,
    ...
  }: {
    config = {
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
    };
  };
}
