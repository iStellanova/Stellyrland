{ config, lib, ... }:
{
  config = lib.mkIf config.aspects.core.enable {
    i18n.defaultLocale = "en_US.UTF-8";
    security.sudo-rs = {
      enable = true;
      extraConfig = "Defaults pwfeedback";
    };
    system.stateVersion = "25.11";
    programs.ssh.startAgent = true;
    services.gnome.gcr-ssh-agent.enable = false;
  };
}
