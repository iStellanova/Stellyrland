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
      imports = with self.modules.homeManager; [
        stellanova
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
