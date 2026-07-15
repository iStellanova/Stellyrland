_: {
  flake.modules.nixos.core =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      time.timeZone = "America/Indianapolis";
      i18n.defaultLocale = "en_US.UTF-8";

      security.sudo.enable = false;
      security.sudo-rs.enable = false;
      security.run0 = {
        enable = true;
        sudo-shim.enable = true;
      };

      # Disable the background.
      environment.systemPackages = [
        (lib.hiPrio (
          pkgs.writeShellScriptBin "run0" ''
            exec ${lib.getExe' config.systemd.package "run0"} --background= "$@"
          ''
        ))
      ];

      system.stateVersion = "25.11";
      documentation.nixos.enable = false;
      programs.ssh.startAgent = true;
      services.gnome.gcr-ssh-agent.enable = false;
      systemd.oomd.enable = true;
      systemd.services."systemd-udevd".serviceConfig = {
        TimeoutStartSec = "10s";
        TimeoutStopSec = "10s";
      };
    };

  flake.modules.homeManager.core = _: {
    home.sessionPath = [ "$HOME/.local/state/nix/profiles/scratch/bin" ];
    home.stateVersion = "25.11";
  };
}
