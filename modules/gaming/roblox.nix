{ inputs, ... }:
{
  flake-file.inputs.nix-flatpak = {
    url = "github:gmodena/nix-flatpak";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.roblox =
    { lib, host, ... }:
    {
      imports = [
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ]
      ++ lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist" = {
          directories = [ "/var/lib/flatpak" ];
          users.${host.username}.directories = [ ".var/app" ];
        };
      };

      services.flatpak = {
        enable = true;
        update.onActivation = true;
        packages = [
          "org.vinegarhq.Sober"
        ];
      };
      systemd.services.flatpak-managed-install = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    };
}
