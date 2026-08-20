{ self, ... }: {
  flake.hosts.stellyrtop = {
    class = "darwin";
    username = "stellanova";
    homeDir = "/Users/stellanova";
    flakePath = "/Users/stellanova/Documents/GitHub/Stellyrland";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    gitSshKey = "~/.ssh/stellacode";
  };

  flake.modules.darwin.stellyrtop = {
    imports = with self.modules.darwin; [
      # Base
      base
      cmdline

      # Desktop
      darwindefs
      homebrew
      maintenance
      omniwm
      kitty
      fonts

      # Gaming
      game-launchers
      steam

      # Media
      media-editing
      obs
      media
      soulseek
      background-sounds

      # Desktop Applications
      zen-browser
      zed

      # Productivity
      finance
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
