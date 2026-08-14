{ inputs, lib, ... }:
{
  # Not follows = "nixpkgs" — this flake's kernel patches are pinned to a
  # specific nixpkgs rev, and our rolling nixos-unstable would risk drift on
  # an already fragile boot chain (m1n1 -> U-Boot -> NixOS). ?rev= also keeps
  # routine bulk write-tack/write-lock runs from sweeping it along with
  # everything else; bump deliberately by changing the rev and re-running them.
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
      # Not inputs.nixos-apple-silicon.packages.${system}.installer-bootstrap
      # — that cross-compiles the *entire* ISO from x86_64, and Hydra never
      # caches cross-compiled derivations, so everything (down to
      # ModemManager) builds from scratch instead of substituting. Hit a real
      # cross-only bug there too (gdbus-codegen producing truncated output).
      #
      # Building natively for aarch64-linux instead (binfmt.nix registers the
      # emulation) gets the generic closure substituting from cache.nixos.org
      # normally. Only the kernel/u-boot/firmware — never cached anywhere —
      # still cross-compile here via hardware.asahi.pkgsSystem, their own
      # documented mechanism for decoupling the two, not a workaround.
      #
      # Uses their pinned nixpkgs (inputs.nixos-apple-silicon.inputs.nixpkgs),
      # not ours — same kernel-patch-compatibility reason as the ?rev= above.
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
