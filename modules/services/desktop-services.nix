{ config, lib, ... }:

{
  options.aspects.services.desktop-services.enable = lib.mkEnableOption "Common desktop services (Flatpak, Indexing, Seahorse)" // { default = true; };

  config = lib.mkIf config.aspects.services.desktop-services.enable {
    services.gnome.tinysparql.enable = true;
    services.gnome.localsearch.enable = true;
    services.flatpak.enable = true;
    programs.seahorse.enable = true;
  };
}
