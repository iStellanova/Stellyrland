{ sn, ... }: {
  sn.nix-base = {
    includes = [ sn.core ];
  };

  sn.core.nixos = _: {
    time.timeZone = "America/Indianapolis";
    i18n.defaultLocale = "en_US.UTF-8";

    security.sudo-rs = {
      enable = true;
      extraConfig = "Defaults pwfeedback";
    };

    system.stateVersion = "25.11";
    programs.ssh.startAgent = true;
    services.gnome.gcr-ssh-agent.enable = false;
    systemd.oomd.enable = true;
    systemd.services."systemd-udevd".serviceConfig = {
      TimeoutStartSec = "10s";
      TimeoutStopSec = "10s";
    };
  };

  # home.username and homeDirectory are set in the stellanova user aspect.
  # home.stateVersion is applied universally via den.default in schema.nix.
  sn.core.homeManager = _: {
    home.sessionPath = [ "$HOME/.local/state/nix/profiles/scratch/bin" ];
  };
}
