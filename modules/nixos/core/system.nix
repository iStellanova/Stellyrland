{ config, lib, ... }:
{
  config = lib.mkIf config.aspects.core.enable {
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
  };
}
