{
  flake.modules.nixos.plasma = {
    services.desktopManager.plasma6.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    services.printing.enable = true;
  };
}
