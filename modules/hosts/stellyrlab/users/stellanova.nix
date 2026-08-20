{ self, ... }:
{
  flake.modules.nixos.stellyrlab = {
    imports = [ self.modules.nixos.stellanova ];

    home-manager.users.stellanova = {
      programs.ssh.settings.stellyrland = {
        HostName = "172.31.255.2";
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
        nvf-ide
        deployment-distributor
      ];
    };
  };
}
