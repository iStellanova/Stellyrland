{
  # No Darwin stanza: these are Linux desktop utilities.
  flake.modules.finix.system-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ gnome-disk-utility mission-center libnotify ];
  };

  flake.modules.nixos.system-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gnome-disk-utility
      mission-center
      libnotify
    ];
  };
}
