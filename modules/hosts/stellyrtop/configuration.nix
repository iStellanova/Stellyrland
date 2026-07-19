{ self, ... }: {
  flake.hosts.stellyrtop = {
    class = "darwin";
    username = "stellanova";
    homeDir = "/Users/stellanova";
    hostName = "stellyrtop";
    flakePath = "/Users/stellanova/Documents/GitHub/Stellyrland";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    gitSshKey = "~/.ssh/stellacode";
  };

  flake.modules.darwin.stellyrtop = {
    imports = with self.modules.darwin; [
      # Base Desktop System
      system-desktop

      # Gaming
      game-launchers
      steam

      # Media
      media-editing
      media
      background-sounds

      # Dev Tools
      ai-tools

      # Desktop Applications
      zen-browser

      # Productivity
      virtual-machines
      finance
      writing
      school
      office-suite
      email
      ide-suite
      cloud-storage
      protonvpn
      psswdmgr

      # Communication
      discord

      # Host Specific Config
      stellyrtop-host
    ];
  };
}
