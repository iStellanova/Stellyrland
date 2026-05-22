{
  lib,
  ...
}: {
  config = {
    # NixOS Core System settings
    flake.modules.nixos.default = {config, ...}: {
      options.aspects.core.enable = lib.mkEnableOption "Core system configuration";

      config = lib.mkIf config.aspects.core.enable {
        time.timeZone = "America/Indianapolis";

        # Locale, don't change.
        i18n.defaultLocale = "en_US.UTF-8";

        # Sudo rs, sudo in rust with password feedback.
        security.sudo-rs = {
          enable = true;
          extraConfig = "Defaults pwfeedback";
        };

        # Installed state, not meant for change.
        system.stateVersion = "25.11";

        # SSH agent start.
        programs.ssh.startAgent = true;

        # Disable the gnome one, use the systemd service instead.
        services.gnome.gcr-ssh-agent.enable = false;

        # Proactive OOM killer to prevent system hangs under extreme memory pressure.
        systemd.oomd.enable = true;

        # Full-system udev timeout — more lenient than initrd (10s vs 5s) because the
        # complete hardware set is present. Prevents Kraken Z USB stalls from hanging
        # boot/shutdown for the default 90s. Counterpart lives in boot.nix (initrd stage).
        systemd.services."systemd-udevd".serviceConfig = {
          TimeoutStartSec = "10s";
          TimeoutStopSec = "10s";
        };
      };
    };

    # Darwin Core System settings
    flake.modules.darwin.default = {config, ...}: {
      options.aspects.core.enable = lib.mkEnableOption "Core system configuration";

      config = lib.mkIf config.aspects.core.enable {
        time.timeZone = "America/Indiana/Indianapolis";
      };
    };

    # Home Manager Core Settings
    flake.modules.homeManager.default = {
      osConfig,
      identity,
      ...
    }:
      lib.mkIf (osConfig ? aspects.core && osConfig.aspects.core.enable) {
        home.username = identity.name;
        home.homeDirectory = identity.home;
        home.stateVersion = "25.11";
        home.sessionPath = ["$HOME/.local/state/nix/profiles/scratch/bin"];
      };
  };
}
