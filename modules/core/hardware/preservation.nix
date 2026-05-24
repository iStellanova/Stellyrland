_: {
  config = {
    # NixOS Preservation Settings
    flake.modules.nixos.preservation = {
      config,
      lib,
      ...
    }: {
      options.aspects.core.preservation.enable = lib.mkEnableOption "Opt-in persistence (wipes / on each boot, keeps only declared paths)";

      config = lib.mkIf config.aspects.core.preservation.enable {
        systemd.tmpfiles.rules = [
          # Returns /etc/nixos's pointer from the config project.
          "L+ /etc/nixos - - - - /home/stellanova/Projects/stellyrland"
        ];

        preservation = {
          enable = true;
          preserveAt."/persist" = {
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
              {
                file = "/etc/ssh/ssh_host_ed25519_key";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_ed25519_key.pub";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_rsa_key";
                how = "symlink";
                configureParent = true;
              }
              {
                file = "/etc/ssh/ssh_host_rsa_key.pub";
                how = "symlink";
                configureParent = true;
              }
            ];
          };
        };
      };
    };
  };
}
