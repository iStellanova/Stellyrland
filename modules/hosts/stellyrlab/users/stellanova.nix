{ self, ... }:
{
  flake.modules.nixos.stellyrlab = {
    imports = [ self.modules.nixos.stellanova ];

    home-manager.users.stellanova =
      { pkgs, ... }:
      let
        deploymentKnownHosts = pkgs.writeText "deployment-known-hosts" ''
          stellyrland.local ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA
          stellyrland.tailb15b96.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA
          stellyrtop.tailb15b96.ts.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuUvoUL9cDXQKdtmHxidbuOK8iuC/ItVWyPFzXySxSm
        '';
      in
      {
        imports = with self.modules.homeManager; [
          base
          cmdline
          fastfetch
          git
          hermes
          nvf-ide
        ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            stellyrland = {
              HostName = "stellyrland.local";
              User = "stellanova";
              IdentityFile = "/run/secrets/stellacode";
              IdentitiesOnly = "yes";
              BatchMode = "yes";
              StrictHostKeyChecking = "yes";
              UserKnownHostsFile = toString deploymentKnownHosts;
            };
            deploy-stellyrland = {
              HostName = "stellyrland.tailb15b96.ts.net";
              User = "stellanova";
              IdentityFile = "/run/secrets/stellyrlab-deploy-key";
              IdentitiesOnly = "yes";
              BatchMode = "yes";
              StrictHostKeyChecking = "yes";
              UserKnownHostsFile = toString deploymentKnownHosts;
            };
            deploy-stellyrtop = {
              HostName = "stellyrtop.tailb15b96.ts.net";
              User = "stellanova";
              IdentityFile = "/run/secrets/stellyrlab-deploy-key";
              IdentitiesOnly = "yes";
              BatchMode = "yes";
              StrictHostKeyChecking = "yes";
              UserKnownHostsFile = toString deploymentKnownHosts;
            };
          };
        };

        services.hermes-serve.enable = true;
      };
  };
}
