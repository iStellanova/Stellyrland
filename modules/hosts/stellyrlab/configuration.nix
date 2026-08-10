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
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
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

      programs.ssh.knownHosts.stellyrland = {
        hostNames = [ "stellyrland.tailb15b96.ts.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPDq0bTLCKn1lKqYn+22wRYiEsNFoMvMlRh1Klm8edA";
      };

      nix = {
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = "stellyrland.tailb15b96.ts.net";
            system = "x86_64-linux";
            protocol = "ssh-ng";
            sshUser = host.username;
            sshKey = config.sops.secrets.stellyrlab-deploy-key.path;
            supportedFeatures = [ "big-parallel" ];
            maxJobs = 1;
            speedFactor = 10;
          }
        ];
      };

      systemd.services.tailscale-settings.script = lib.mkForce "${pkgs.tailscale}/bin/tailscale set --accept-dns=true --accept-routes=false --ssh=false";

      # The controller needs kernel networking so normal SSH can use MagicDNS.
      services.tailscale = {
        interfaceName = lib.mkForce "tailscale0";
        extraUpFlags = lib.mkForce [
          "--accept-dns=true"
          "--accept-routes=false"
          "--ssh=false"
        ];
      };
    };
}
