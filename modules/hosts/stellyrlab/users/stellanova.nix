{ self, ... }:
{
  modules.nixos.stellyrlab.stellanova = {
    imports = [
      (self.factory.user "stellanova").nixos.stellanova
      self.modules.nixos.stellanova
    ];

    security.nix-secrets.secrets.stellacode = {
      recipients = [
        "stellanova"
        "stellyrlab"
      ];
      owner = "stellanova";
      mode = "0600";
      path = "/run/secrets/stellacode";
    };

    home-manager.users.stellanova = {
      programs.ssh.settings.stellyrlab = {
        HostName = "stellyrlab.tailb15b96.ts.net";
        User = "stellanova";
        IdentityFile = "/run/secrets/stellacode";
        IdentitiesOnly = "yes";
      };

      imports = with self.modules.homeManager; [
        base
        cmdline
        fastfetch
        git
        hermes
        zed
        fleet-build
        nvf-ide
      ];
    };
  };
}
