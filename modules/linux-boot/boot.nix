{
  sn,
  inputs,
  ...
}:
{
  sn.linux-boot = {
    includes = [ sn.boot ];
  };

  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  sn.boot.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      options.core.boot.secureBoot = lib.mkEnableOption "Lanzaboote Secure Boot (disable for initial install)";

      config = {
        environment.systemPackages = [
          pkgs.efibootmgr
          pkgs.sbctl
        ];

        # lanzaboote wraps systemd-boot to produce signed UKIs on every rebuild;
        # the stock systemd-boot module must be force-disabled to avoid conflicts.
        # Disabled for initial install (Rust stub builds from source, fails on live USB);
        # run nixos-rebuild with secureBoot = true after first boot to switch.
        boot.loader.systemd-boot = {
          enable = lib.mkForce (!config.core.boot.secureBoot);
          configurationLimit = 15;
          consoleMode = "max";
        };
        boot.loader.efi.canTouchEfiVariables = true;

        boot.lanzaboote = {
          enable = config.core.boot.secureBoot;
          pkiBundle = "/var/lib/sbctl";
        };
      };
    };
}
