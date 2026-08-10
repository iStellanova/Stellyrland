{ self, ... }:
{
  flake.modules.nixos.stellyrlab = {
    imports = [ self.modules.nixos.stellanova ];

    home-manager.users.stellanova =
      { pkgs, ... }:
      let
        stellyrlandKnownHost = pkgs.writeText "stellyrland-known-host" ''
          stellyrland.local ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA
        '';
      in
      {
        imports = with self.modules.homeManager; [
          base
          cmdline
          fastfetch
          hermes
        ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings.stellyrland = {
            HostName = "stellyrland.local";
            User = "stellanova";
            IdentityFile = "/run/secrets/stellacode";
            IdentitiesOnly = "yes";
            BatchMode = "yes";
            StrictHostKeyChecking = "yes";
            UserKnownHostsFile = toString stellyrlandKnownHost;
          };
        };

        services.hermes-serve.enable = true;
      };
  };
}
