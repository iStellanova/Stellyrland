{
  config,
  lib,
  ...
}: {
  options.aspects.services.desktop-services.enable = lib.mkEnableOption "Common desktop services (Flatpak, Indexing, Seahorse)";

  config = lib.mkIf config.aspects.services.desktop-services.enable {
    # TinySPARQL and LocalSearch provide the indexing backend for Nautilus file searching.
    services.gnome.tinysparql.enable = true;
    services.gnome.localsearch.enable = true;
    services.flatpak = {
      enable = true;
      update.onActivation = true;
      packages = [
        "org.vinegarhq.Sober"
      ];
    };
    programs.seahorse.enable = true; # GUI for managing GPG keys and SSH passwords
  };
}
