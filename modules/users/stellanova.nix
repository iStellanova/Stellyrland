{ self, ... }:
let
  user = self.factory.user "stellanova";
in
{
  flake.modules = user // {
    homeManager = user.homeManager // {
      stellanova = {
        home = {
          username = "stellanova";
          homeDirectory = "/home/stellanova";
          stateVersion = "25.11";
        };
        programs.ssh.settings.stellyrlab = {
          HostName = "stellyrlab.tailb15b96.ts.net";
          User = "stellanova";
          IdentityFile = "/run/secrets/stellacode";
          IdentitiesOnly = "yes";
        };
      };
    };

    nixos.stellanova =
      {
        host,
        lib,
        ...
      }:
      {
        security.nix-secrets.secrets.stellacode =
          lib.mkIf
            (builtins.elem host.name [
              "stellyrlab"
              "stellyrland"
            ])
            {
              recipients = [
                "stellanova"
                host.name
              ];
              owner = host.username;
              mode = "0600";
              path = "/run/secrets/stellacode";
            };
        imports = [
          user.nixos.stellanova
          self.modules.nixos.accessor
        ];
      };
    darwin.stellanova = {
      imports = [
        user.darwin.stellanova
        self.modules.darwin.accessor
      ];
    };
  };
}
