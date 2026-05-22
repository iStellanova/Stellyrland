_: {
  config = {
    # NixOS Impermanence Settings
    flake.modules.nixos.impermanence = {
      config,
      lib,
      ...
    }: {
      options.aspects.core.impermanence.enable = lib.mkEnableOption "Opt-in persistence (wipes / on each boot, keeps only declared paths)";

      config = lib.mkIf config.aspects.core.impermanence.enable {
        systemd.tmpfiles.rules = [
          # Returns /etc/nixos's pointer from the config project.
          "L+ /etc/nixos - - - - /home/stellanova/Projects/stellyrland"
        ];

        environment.persistence."/persist" = {
          hideMounts = true;
          directories = [
            "/var/lib/sbctl"
            "/var/lib/nixos"
            "/var/lib/postgresql"
            "/var/lib/private/ollama"
            "/var/lib/private/open-webui"
            "/var/lib/tailscale"
            "/var/lib/bluetooth"
            "/var/lib/NetworkManager"
            "/var/lib/iwd"
            "/etc/NetworkManager"
            "/var/log"
            "/var/lib/regreet"
          ];
          files = [
            "/etc/adjtime"
            "/etc/machine-id"
            "/etc/ssh/ssh_host_ed25519_key"
            "/etc/ssh/ssh_host_ed25519_key.pub"
            "/etc/ssh/ssh_host_rsa_key"
            "/etc/ssh/ssh_host_rsa_key.pub"
          ];
        };
      };
    };
  };
}
