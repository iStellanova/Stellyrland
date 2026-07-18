{ self, ... }: {
  flake.hosts.onitop = {
    class = "nixos";
    username = "oni";
    homeDir = "/home/oni";
    hostName = "onitop";
    flakePath = "/home/oni/Projects/stellyrland";
    passwordSecret = "onipsswd";
  };

  flake.modules.nixos.onitop = {
    imports = with self.modules.nixos; [
      # Base System
      system-cli

      # Desktop
      plasma
      fonts
      pipewire

      # Host Specific Config
      onitop-host
    ];
  };
}
