{ self, ... }: {
  flake.hosts.stellyrland = {
    class = "finix";
    uid = 1000;
    username = "stellanova";
    homeDir = "/home/stellanova";
    persistence = true;
    flakePath = "/home/stellanova/Projects/stellyrland";
    passwordSecret = "stellapsswd";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    gitSshKey = "/run/secrets/stellacode";

    backup = {
      receiver = {
        address = "172.31.255.1";
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCz+XUleiNbgSwcZHvxOXXTbihnTIRoDKoXr+2zCSgA";
      };
      datasets = {
        home = "zroot/safe/home";
        persist = "zroot/safe/persist";
      };
    };
    graphics = "amd";
    monitorPriority = [
      "DP-2"
      "DP-3"
    ];
    features.hdr = true;
  };

  flake.modules.finix.stellyrland = {
    imports = with self.modules.finix; [
      base
      cmdline
      services-base
      fonts
      xdg
      pipewire
      pipewire-lowlatency
      noctalia-greeter
      hyprland
      noctalia
      openrgb
      limine
      zed
      opencode
      nautilus
      steam
      gamescope
      game-launchers
      stellanova
      stellyrland-host
    ];
  };
}
