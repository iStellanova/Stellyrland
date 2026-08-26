{ inputs, ... }:
{
  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";

  flake.modules.finix.flatpak =
    { inputs, ... }:
    {
      imports = [ inputs.finix.nixosModules.flatpak ];
      services.flatpak.enable = true;
    };

  flake.modules.nixos.flatpak =
    {
      lib,
      host,
      ...
    }:
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
          "io.github.kolunmi.Bazaar"
        ];
      };
      # nix-flatpak's own unit only orders after multi-user.target, so a flatpak
      # install can run before the network is up and fail.
      systemd.services.flatpak-managed-install = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };

    };
}
