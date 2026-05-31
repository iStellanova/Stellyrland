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
      "ai"
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

        desktop.gaming.hdr.enable = true;

        desktop.hyprland.wallpaperEngine.workshopId = "3258032485";

        desktop.noctalia.primaryMonitor = "DP-2";
        desktop.noctalia.secondaryMonitor = "DP-3";

        desktop.hyprland.monitorConfig = ''
          hl.monitor({ output = "DP-2", mode = "3440x1440@175", position = "1440x541", scale = 1, bitdepth = 10, cm = "hdr", supports_wide_color = 1, sdr_min_luminance = 0.0,  sdr_max_luminance = 203, sdrbrightness = 0.75, sdrsaturation = 1.2, min_luminance = 0.0005, max_luminance = 1000, max_avg_luminance = 250 })
          hl.monitor({ output = "DP-3", mode = "2560x1440@100", position = "0x0",    scale = 1, transform = 1, bitdepth = 10, cm = "srgb", sdr_min_luminance = 0.2, min_luminance = 0.25, max_luminance = 250, max_avg_luminance = 250 })
          hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
        '';
      }
    ];
  };
}
