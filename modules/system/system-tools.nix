_: {
  flake.modules.nixos.system-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gnome-disk-utility
      mission-center
    ];
  };
}
