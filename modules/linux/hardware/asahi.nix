{ inputs, lib, ... }:
{
  # Keep pinned: the kernel patches must match the upstream nixpkgs revision.
  flake-file.inputs.nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon?rev=3902c801519264191a7c3dfec8dd1f9faeb38fd5";

  flake.modules.nixos.asahi = {
    imports = [ inputs.nixos-apple-silicon.nixosModules.apple-silicon-support ];

    hardware.asahi.enable = true;

    # systemd-boot, not GRUB — GRUB is only what their installer ISO bundles
    # internally (see uefi-standalone.md). m1n1/U-Boot own the EFI vars here,
    # so NixOS touching them isn't supported.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
  };

  perSystem =
    { system, ... }:
    lib.optionalAttrs (system == "x86_64-linux") {
      # Evaluate the installer for aarch64 under x86 binfmt; keep its pinned
      # nixpkgs and cross-build only the hardware-specific components.
      packages.asahi-installer =
        let
          asahiNixpkgs = inputs.nixos-apple-silicon.inputs.nixpkgs;
          installer-system = asahiNixpkgs.lib.nixosSystem {
            specialArgs.modulesPath = asahiNixpkgs + "/nixos/modules";
            modules = [
              inputs.nixos-apple-silicon.nixosModules.apple-silicon-installer
              {
                nixpkgs.hostPlatform.system = "aarch64-linux";
                hardware.asahi.pkgsSystem = system;
                nixpkgs.overlays = [ inputs.nixos-apple-silicon.overlays.default ];
              }
            ];
          };
        in
        installer-system.config.system.build.isoImage;
    };
}
