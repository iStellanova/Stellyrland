{
  config,
  lib,
  pkgs,
  ...
}: let
  # Automated Secure Boot PKI key enrollment helper
  stellyr-secureboot-setup = pkgs.writeShellScriptBin "stellyr-secureboot-setup" ''
    set -euo pipefail

    if [ "$EUID" -ne 0 ]; then
      echo "ERROR: Please run this script with sudo!"
      exit 1
    fi

    echo "Stellyrland: Beginning Secure Boot key enrollment..."
    if ! sbctl status | grep -q "Setup Mode:   enabled"; then
      echo "ERROR: System is not in Setup Mode! Please clear keys in your UEFI/BIOS first."
      exit 1
    fi

    echo "1. Generating Secure Boot keys..."
    sbctl create-keys

    echo "2. Enrolling Secure Boot keys (with Microsoft OEM signatures)..."
    sbctl enroll-keys --microsoft

    echo "SUCCESS: Secure Boot keys successfully enrolled!"
    echo "Next Step: Toggle 'secureBoot = true' in default.nix, run 'nixos-rebuild switch', and enable Secure Boot in your BIOS."
  '';

  # Automated TPM2 auto-unlock enrollment helper
  stellyr-tpm-setup = pkgs.writeShellScriptBin "stellyr-tpm-setup" ''
    set -euo pipefail

    if [ "$EUID" -ne 0 ]; then
      echo "ERROR: Please run this script with sudo!"
      exit 1
    fi

    echo "Stellyrland: Enrolling TPM2 auto-unlock keys..."

    echo "1. Enrolling Primary Partition (cryptroot)..."
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 /dev/disk/by-partlabel/disk-main-root

    echo "2. Enrolling Secondary Partition (cryptextra)..."
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 /dev/disk/by-partlabel/disk-extra-luks

    echo "SUCCESS: TPM2 keys successfully enrolled for both LUKS containers!"
  '';
in {
  options.aspects.core.setup.enable = lib.mkEnableOption "First-boot bootstrap and onboarding helper scripts";

  config = lib.mkIf config.aspects.core.setup.enable {
    environment.systemPackages =
      lib.optional config.aspects.core.boot.enable stellyr-secureboot-setup
      ++ lib.optional config.aspects.core.extra-disk.enable stellyr-tpm-setup;
  };
}
