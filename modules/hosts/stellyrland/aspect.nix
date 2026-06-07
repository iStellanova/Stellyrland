{den, ...}: {
  den.aspects.stellyrland = {
    includes = [
      den.aspects.core
      den.aspects.nix-settings
      den.batteries.hostname
      den.aspects.networking
      den.aspects.users
      den.aspects.xdg
      den.aspects.fonts
      den.aspects.homebrew
      den.aspects.services-base
      den.aspects.boot
      den.aspects.headless
      den.aspects.initrd
      den.aspects.kernel
      den.aspects.kernel-params
      den.aspects.hardware
      den.aspects.extra-disk
      den.aspects.hdd
      den.aspects.preservation
      den.aspects.storage
      den.aspects.secrets
      den.aspects.aesthetic
      den.aspects.styling
      den.aspects.hyprland
      den.aspects.vesktop
      den.aspects.nix-index
      den.aspects.ai-tools
      den.aspects.kitty
      den.aspects.ns
      den.aspects.ide-suite
      den.aspects.cli
      den.aspects.helix
      den.aspects.git
      den.aspects.yazi
      den.aspects.zed
      den.aspects.gaming
      den.aspects.gsr
      den.aspects.media-editing
      den.aspects.cava
      den.aspects.media
      den.aspects.office-suite
      den.aspects.school
      den.aspects.virtual-machines
      den.aspects.noctalia-shell
      den.aspects.utils
      den.aspects.maintenance
      den.aspects.btop
      den.aspects.fastfetch
      den.aspects.nautilus
      den.aspects.bitwarden
      den.aspects.browser
      den.aspects.zsh
      den.aspects.greetd
      den.aspects.coolercontrol
      den.aspects.lact
      den.aspects.openssh
      den.aspects.seahorse
      den.aspects.flatpak
      den.aspects.discord-music-rpc
      den.aspects.openrgb
    ];

    nixos = {host, ...}: {
      imports = [./_hardware-configuration.nix];

      core.boot.secureBoot = host.features.secureBoot;
      core.headless.disabledPorts = [
        "DP-2"
        "DP-3"
      ];
      core.nix-settings.cores = 24;

      desktop.gaming.hdr.enable = host.features.hdr;

      desktop.hyprland.wallpaperEngine.steamLibrary = "/ExtraDisk";
      desktop.hyprland.wallpaperEngine.workshopId = "3258032485";

      desktop.noctalia.primaryMonitor = "DP-2";
      desktop.noctalia.secondaryMonitor = "DP-3";

      desktop.hyprland.monitorConfig = ''
        hl.monitor({ output = "DP-2", mode = "3440x1440@175", position = "1440x541", scale = 1, bitdepth = 10, cm = "hdr", supports_wide_color = 1, sdr_min_luminance = 0.0,  sdr_max_luminance = 203, sdrbrightness = 0.75, sdrsaturation = 1.2, min_luminance = 0.0005, max_luminance = 1000, max_avg_luminance = 250 })
        hl.monitor({ output = "DP-3", mode = "2560x1440@100", position = "0x0",    scale = 1, transform = 1, bitdepth = 10, cm = "srgb", sdr_min_luminance = 0.2, min_luminance = 0.25, max_luminance = 250, max_avg_luminance = 250 })
        hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
      '';

      desktop.hyprland.greetdMonitorConfig = ''
        hl.monitor({ output = "DP-2", mode = "3440x1440@175", position = "1440x541", scale = 1 })
        hl.monitor({ output = "DP-3", mode = "2560x1440@100", position = "0x0",    scale = 1, transform = 1 })
        hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
      '';
    };
  };
}
