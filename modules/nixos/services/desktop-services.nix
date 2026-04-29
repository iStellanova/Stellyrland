{ config, lib, ... }:

{
  options.aspects.services.desktop-services.enable = lib.mkEnableOption "Common desktop services (Flatpak, Indexing, Seahorse)" // { default = true; };

  config = lib.mkIf config.aspects.services.desktop-services.enable {
    services.gnome.tinysparql.enable = true; # Enable TinySPARQL, a GNOME service for indexing.
    services.gnome.localsearch.enable = true; # Enable LocalSearch, a GNOME service for local file indexing.
    services.flatpak.enable = true; # Enable Flatpak, a cross-distribution package manager.
    programs.seahorse.enable = true; # Enable Seahorse, a GNOME password manager.
  };
}
