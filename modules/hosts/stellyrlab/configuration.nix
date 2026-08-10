{ self, ... }: {
  flake.hosts.stellyrlab = {
    class = "nixos";
    username = "stellanova";
    homeDir = "/home/stellanova";
    flakePath = "/home/stellanova/Projects/stellyrland";
    passwordSecret = "stellapsswd";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    gitSshKey = "/run/secrets/stellacode";
    sshKeys = self.constants.sshKeys;
  };

  flake.modules.nixos.stellyrlab =
    { host, lib, ... }:
    {
      imports = with self.modules.nixos; [
        base
        boot
        cmdline
        maintenance
        personal-secrets
        stellyrlab-host
      ];

      sops.secrets.stellyrlab-deploy-key = {
        owner = host.username;
        mode = "0600";
      };

      # The controller needs kernel networking so normal SSH can use MagicDNS.
      services.tailscale = {
        interfaceName = lib.mkForce "tailscale0";
        extraUpFlags = lib.mkForce [
          "--accept-dns=true"
          "--accept-routes=false"
          "--ssh"
        ];
      };
    };
}
