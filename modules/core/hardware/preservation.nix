{inputs, ...}: {
  # NixOS Preservation Settings
  flake.modules.nixos.preservation = {config, ...}: {
    imports = [inputs.preservation.nixosModules.preservation];

    config = {
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
          users.${config.identity.username} = {
            directories = [
              # User data
              "Projects"
              "Documents"
              "Pictures"
              "Music"
              "Videos"

              # Credentials
              ".ssh"
              ".local/share/keyrings"
              ".gnupg"

              # Browser profile (bookmarks, history, logins, cookies)
              ".config/zen"

              # App sessions and runtime state
              ".config/vesktop"
              ".config/gemini"
              ".claude"
              ".antigravity"
              ".antigravity-ide-server"

              # Editor runtime (extensions, compiled LSPs)
              ".local/share/zed"

              # Steam client data (game library lives on ExtraDisk)
              ".local/share/Steam"
              ".steam"

              # Game launchers and saves
              ".local/share/PrismLauncher"
              ".config/heroic"
              ".local/share/r2modman"

              # Flatpak user app data
              ".var/app"
            ];
            files = [
              {
                file = ".zsh_history";
                how = "symlink";
              }
            ];
          };
        };
      };
    };
  };
}
