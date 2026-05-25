{inputs, ...}: {
  # NixOS Bootloader Settings
  flake.modules.nixos.boot = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    options.aspects.core.boot = {
      enable = lib.mkEnableOption "Bootloader configuration";
      secureBoot = lib.mkEnableOption "Lanzaboote Secure Boot (disable for initial install)";
    };

    config = lib.mkIf config.aspects.core.boot.enable {
      environment.systemPackages = [pkgs.efibootmgr pkgs.sbctl];

      # systemd-boot is managed by lanzaboote, which wraps it to produce
      # signed Unified Kernel Images on every nixos-rebuild. The stock
      # systemd-boot module must be force-disabled to avoid conflicts.
      # lanzaboote is disabled for initial install — its Rust stub must be built
      # from source when not cached, which fails in the live USB environment.
      # After first boot, run nixos-rebuild with secureBoot = true to switch.
      boot.loader.systemd-boot = {
        enable = lib.mkForce (!config.aspects.core.boot.secureBoot);
        configurationLimit = 15;
        consoleMode = "max";
      };
      boot.loader.efi.canTouchEfiVariables = true;

      boot.lanzaboote = {
        enable = config.aspects.core.boot.secureBoot;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
