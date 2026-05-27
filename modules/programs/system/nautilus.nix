_: {
  # NixOS Nautilus Settings
  flake.modules.nixos.nautilus = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        nautilus
        sushi
        evince
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
      ];

      services.gnome.tinysparql.enable = true;
      services.gnome.localsearch.enable = true;
    };
  };
}
