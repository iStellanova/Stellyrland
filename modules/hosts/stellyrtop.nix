{inputs, ...}: {
  hosts.darwin.stellyrtop = {
    system = "aarch64-darwin";

    aspects = [
      "core"
      "homebrew"
      "users"
      "fonts"
      "nix-settings"
      "networking"
      "aerospace"
      "aesthetic"
      "browser"
      "background-sounds"
      "maintenance"
      "finance"
      "school"
      "writing"
      "cloud-storage"
      "virtual-machines"
      "media"
      "media-editing"
      "btop"
      "cava"
      "cli"
      "fastfetch"
      "gaming"
      "git"
      "kitty"
      "nix-index"
      "ns"
      "yazi"
      "zsh"
      "nixvim"
      "ai-tools"
      "bitwarden"
      "ide-suite"
      "office-suite"
      "vesktop"
      "utils"
      "zed"
      "discord-music-rpc"
      "helix"
    ];

    modules = [
      # Identity configuration
      {
        identity = {
          username = "stellanova";
          homeDir = "/Users/stellanova";
          gitName = "stellanova";
          userEmail = "iStellanova@users.noreply.github.com";
          sshKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
          ];
          dataPath = inputs.my-assets;
        };
      }

      # Host-specific configuration
      {
        system.stateVersion = 5;

        networking = {
          computerName = "Stellyrtop";
          hostName = "stellyrtop";
          localHostName = "stellyrtop";
        };

        # Directly configure custom overrides using option namespaces
        darwin.system.dockApps = [
          "/System/Applications/App Store.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Messages.app"
          "/System/Applications/Passwords.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Stickies.app"
          "/Applications/DaVinci Resolve/DaVinci Resolve.app"
          "/Applications/Quicken.app"
          "/Applications/Microsoft Word.app"
          "/Applications/Microsoft PowerPoint.app"
          "/Applications/Microsoft Excel.app"
          "/Applications/Microsoft OneNote.app"
          "/Applications/Microsoft Outlook.app"
          "/Applications/School Assistant.app"
          "/System/Applications/Books.app"
          "/Applications/Pages Creator Studio.app"
          "/Applications/Keynote Creator Studio.app"
          "/Applications/Numbers Creator Studio.app"
          "/System/Applications/Music.app"
          "/Applications/Antigravity.app"
          "/Applications/Beat.app"
          "/Applications/Claude.app"
          "/Users/stellanova/Applications/Home Manager Apps/kitty.app"
          "/Applications/Zen Browser.app"
        ];
      }
    ];
  };
}
