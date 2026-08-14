{ inputs, ... }:
{
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.boot =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ]
      ++ lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".directories = [ "/var/lib/sbctl" ];
      };

      config = {

        environment.systemPackages = [
          pkgs.efibootmgr
          pkgs.sbctl
        ];

        # Lanzaboote wraps systemd-boot to produce signed UKIs on every rebuild;
        # the stock systemd-boot module must be force-disabled to avoid conflicts.
        boot.loader.systemd-boot = {
          enable = lib.mkForce false;
          configurationLimit = 15;
          consoleMode = "max";
        };
        boot.loader.efi.canTouchEfiVariables = true;

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
      };
    };
}
