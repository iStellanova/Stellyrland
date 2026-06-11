{
  sn,
  inputs,
  ...
}: {
  sn.linux-storage = {includes = [sn.preservation];};

  flake-file.inputs.preservation.url = "github:nix-community/preservation";

  sn.preservation.nixos = {host, ...}: {
    imports =
      if inputs ? preservation
      then [inputs.preservation.nixosModules.preservation]
      else [];

    systemd.tmpfiles.rules = [
      # Returns /etc/nixos's pointer from the config project.
      "L+ /etc/nixos - - - - ${host.homeDir}/Projects/stellyrland"

      # The @blank ZFS snapshot was taken before nixos-install ran, so the home
      # dataset root reverts to root:root after every rollback. Preservation's
      # tmpfiles creates subdirs fine (root can do that) but HM runs as the user
      # and can't create ~/.cache etc. in a root-owned directory. Fix ownership.
      "d /home/${host.username} 0700 ${host.username} users -"

      # home-manager-stellanova.service runs at boot (before user login) and calls
      # setupVars, which exits 1 if neither ~/.local/state/nix/profiles nor
      # /nix/var/nix/profiles/per-user/$USER exists. After ZFS rollback both are
      # gone; the service tries to recreate the former via `nix-env -q` but that
      # relies on a login-shell PATH that isn't guaranteed at pre-login boot time.
      # Persisting these directories means setupVars always finds what it needs.
      "d /persist/home/${host.username}/.local/state/nix/profiles 0755 ${host.username} users -"
      "d /persist/home/${host.username}/.local/state/home-manager/gcroots 0755 ${host.username} users -"
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
            ".local/share/PrismLauncher"
            ".config/heroic"
            ".local/share/r2modman"

            # Nix user state — profile dir must survive rollback so
            # home-manager-stellanova.service's setupVars() doesn't exit 1 at boot
            ".local/state/nix"

            # HM gcroots — protects current generation from nix-store GC and
            # gives HM its oldGenPath for correct diff-based activation
            ".local/state/home-manager"

            # Audio session volumes and per-app mix
            ".local/state/wireplumber"

            # Music library database and cover cache
            ".local/share/lollypop"

            # Hyprland version tracking — prevents "what's new" popup on every boot
            ".local/share/hyprland"

            # Zoxide jump database — accumulated frecency weights for smart cd
            ".local/share/zoxide"

            # Flatpak user app data
            ".var/app"
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
