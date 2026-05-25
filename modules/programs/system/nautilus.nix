_: {
  flake.modules.nixos.nautilus = {pkgs, ...}: {
    config = {
      environment.systemPackages = with pkgs; [
        nautilus
        sushi
      ];

      services.gnome.tinysparql.enable = true;
      services.gnome.localsearch.enable = true;
    };
  };
}
