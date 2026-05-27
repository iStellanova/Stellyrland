_: {
  # NixOS Nautilus Settings
  flake.modules.nixos.nautilus = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        nautilus
        sushi
        evince
      ];

      services.gnome.tinysparql.enable = true;
      services.gnome.localsearch.enable = true;
    };
  };
}
