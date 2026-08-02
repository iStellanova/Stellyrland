_: {
  # No darwin stanza: these are GNOME-specific system utilities, no macOS equivalent.
  flake.modules.nixos.system-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gnome-disk-utility
      mission-center
      libnotify
    ];
  };
}
