{ inputs, ... }:
{
  flake-file.inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";

  flake.modules.finix.roblox =
    { inputs, host, pkgs, ... }:
    {
      imports = [ inputs.finix.nixosModules.flatpak ];
      services.flatpak.enable = true;
      finit.tasks.sober-install = {
        conditions = [
          "service/network-manager/ready"
          "service/dbus/ready"
        ];
        command = pkgs.writeShellScript "sober-install" ''
          ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
          ${pkgs.flatpak}/bin/flatpak install --system --noninteractive flathub org.vinegarhq.Sober
        '';
      };
      preservation.preserveAt."/persist" = {
        directories = [ "/var/lib/flatpak" ];
        users.${host.username}.directories = [ ".var/app" ];
      };
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
