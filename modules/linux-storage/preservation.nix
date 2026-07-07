{
  sn,
  inputs,
  ...
}:
{
  sn.linux-storage = {
    includes = [ sn.preservation ];
  };

  flake-file.inputs.preservation = {
    url = "github:nix-community/preservation";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.preservation.nixos = { host, ... }: {
    imports = [ inputs.preservation.nixosModules.preservation ];

    systemd.tmpfiles.rules = [
      # Returns /etc/nixos's pointer from the config project.
      "L+ /etc/nixos - - - - ${host.flakePath}"

      # @blank was taken before nixos-install, so home reverts to root:root after rollback;
      # fix ownership so HM can create ~/.cache etc. as the user.
      "d /home/${host.username} 0700 ${host.username} users -"
    ];

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/var/lib/sbctl"
          "/var/lib/nixos"
          "/var/lib/tailscale"
          "/var/lib/NetworkManager"
          "/etc/NetworkManager"
          "/var/log"
          "/var/lib/noctalia-greeter"
          "/var/lib/flatpak"
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
        users.${host.username} = {
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
            ".local/share/Paradox Interactive"
            ".local/share/PrismLauncher"

            ".local/share/r2modman"

            # Nix user state — profile dir must survive rollback so
            # home-manager-stellanova.service's setupVars() doesn't exit 1 at boot
            {
              directory = ".local/state/nix/profiles";
              mode = "0755";
            }
            ".local/state/nix"

            # HM gcroots — protects current generation from nix-store GC and
            # gives HM its oldGenPath for correct diff-based activation
            {
              directory = ".local/state/home-manager/gcroots";
              mode = "0755";
            }
            ".local/state/home-manager"

            # Audio session volumes and per-app mix
            ".local/state/wireplumber"

            # Hyprland version tracking — prevents "what's new" popup on every boot
            ".local/share/hyprland"

            # Zoxide jump database — accumulated frecency weights for smart cd
            ".local/share/zoxide"

            # direnv allow list — prevents re-allow after every rollback
            ".local/share/direnv"

            # Flatpak user app data
            ".var/app"

            # OpenVR driver path registry — ALVR/Space Calibrator need re-registering without this
            ".config/openvr"

            # ALVR session.json (paired Quest client, ALVR settings)
            ".config/alvr"

            # Space Calibrator playspace calibration profiles
            ".config/space-calibrator"

            # OpenXR active runtime pointer (set via "Set as default" in SteamVR)
            ".config/openxr"

            # ADB USB-debugging trust keypair — avoids re-approving the Quest every boot
            ".android"
          ];
          files = [
            {
              file = ".zsh_history";
              how = "symlink";
            }
            {
              file = ".claude.json";
              how = "symlink";
            }
            # Noctalia runtime data — configureParent creates .local/state/noctalia/ at boot
            {
              file = ".local/state/noctalia/screen_time.json";
              how = "symlink";
              configureParent = true;
            }
            {
              file = ".local/state/noctalia/usage_counts.json";
              how = "symlink";
              configureParent = true;
            }
            {
              file = ".local/state/noctalia/recently_used.json";
              how = "symlink";
              configureParent = true;
            }
            {
              file = ".local/state/noctalia/notification_history.json";
              how = "symlink";
              configureParent = true;
            }
          ];
        };
      };
    };
  };
}
