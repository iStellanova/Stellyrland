{inputs, ...}: {
  hosts.nixos.stellyrland = {
    system = "x86_64-linux";

    aspects = [
      "core"
      "nix-settings"
      "hardware"
      "boot"
      "initrd"
      "kernel"
      "kernel-params"
      "fonts"
      "networking"
      "storage"
      "extra-disk"
      "hdd"
      "preservation"
      "services-base"
      "users"
      "xdg"
      "headless"
      "secrets"
      "styling"
      "hyprland"
      "cli"
      "ai-tools"
      "aesthetic"
      "background-sounds"
      "maintenance"
      "media"
      "media-editing"
      "utils"
      "browser"
      "gaming"
      "git"
      "zsh"
      "nixvim"
      "bitwarden"
      "vesktop"
      "noctalia-shell"
      "btop"
      "cava"
      "fastfetch"
      "gsr"
      "kitty"
      "nix-index"
      "ns"
      "yazi"
      "nautilus"
      "zed"
      "openssh"
      "discord-music-rpc"
      "greetd"
      "flatpak"
      "seahorse"
      "coolercontrol"
      "lact"
      "openrgb"
    ];

    modules = [
      # Identity configuration
      {
        identity = {
          username = "stellanova";
          homeDir = "/home/stellanova";
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
        imports = [./stellyrland/_hardware-configuration.nix];

        networking.hostName = "stellyrland";

        # Directly configure custom overrides using option namespaces
        core.boot.secureBoot = true;
        core.headless.disabledPorts = [
          "DP-2"
          "DP-3"
        ];
        core.nix-settings.cores = 24;

        desktop.hyprland.wallpaperEngine.workshopId = "3258032485";
      }
    ];
  };
}
