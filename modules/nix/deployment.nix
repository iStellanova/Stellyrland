let
  target = {
    hostNames = [
      "172.31.255.2"
      "stellyrland.local"
      "stellyrland.tailb15b96.ts.net"
    ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA";
  };
in
{
  flake.modules.nixos.deployment-distributor =
    {
      config,
      host,
      ...
    }:
    {
      security.nix-secrets.secrets.stellacode = {
        recipients = [
          "stellanova"
          host.name
        ];
        owner = host.username;
        mode = "0600";
      };

      programs.ssh.knownHosts.stellyrland = {
        inherit (target) hostNames publicKey;
      };

      nix = {
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = builtins.head target.hostNames;
            system = "x86_64-linux";
            protocol = "ssh-ng";
            sshUser = host.username;
            sshKey = config.security.nix-secrets.secrets.stellacode.path;
            supportedFeatures = [ "big-parallel" ];
            maxJobs = 1;
            speedFactor = 10;
          }
        ];
      };
    };
}
