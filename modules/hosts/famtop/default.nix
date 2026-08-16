{
  flake.modules.nixos.famtop-host =
    { host, ... }:
    {
      imports = [ ./_hardware-configuration.nix ];

      networking.hostName = host.name;

      # Separate encrypted file, own recipient list — famtop must never
      # decrypt stellyrland's personal secrets (see secrets/.sops.yaml).
      sops.defaultSopsFile = ../../../secrets/famtop.yaml;

      # The module's own default auto-detects this on /boot/vendorfw or
      # /mnt/boot/vendorfw — fine building on famtop itself, but those never
      # exist on stellyrland, which is what actually builds this for remote
      # deploys. Non-free, non-redistributable firmware.cpio lives outside
      # the repo, copied once to stellyrland's persist storage; re-copy if
      # it ever needs regenerating.
      hardware.asahi.peripheralFirmwareDirectory = /persist/home/stellanova/.local/share/asahi-firmware/famtop;
    };
}
