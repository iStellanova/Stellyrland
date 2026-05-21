{
  config,
  lib,
  ...
}: {
  # Opt-in persistence: / is wiped on every boot (@ reset to @blank).
  # /nix, /persist, and /home are separate subvolumes and survive every reboot.
  # Only paths declared below in environment.persistence are kept across boots.
  #
  # Reference: https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html
  # Impermanence module: https://github.com/nix-community/impermanence

  options.aspects.core.impermanence.enable = lib.mkEnableOption "Opt-in persistence (wipes / on each boot, keeps only declared paths)";

  config = lib.mkIf config.aspects.core.impermanence.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/nixos"
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
}
