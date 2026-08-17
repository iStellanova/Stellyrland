{ self, ... }:
let
  user = self.factory.user "stellanova";
in
{
  flake.modules = user // {
    homeManager = user.homeManager // {
      stellanova = {
        programs.ssh.settings.stellyrlab = {
          HostName = "stellyrlab.tailb15b96.ts.net";
          User = "stellanova";
          IdentityFile = "/run/secrets/stellacode";
          IdentitiesOnly = "yes";
        };
      };
    };

    nixos.stellanova = {
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
