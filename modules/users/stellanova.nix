{ ... }:
let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
  ];
in
{
  modules.nixos.stellanova =
    { lib, ... }:
    {
      users.users.stellanova = {
        openssh.authorizedKeys.keys = sshKeys;
        isNormalUser = true;
        home = "/home/stellanova";
        extraGroups = lib.mkDefault [ "wheel" ];
      };
    };

  modules.darwin.stellanova = {
    users.users.stellanova.openssh.authorizedKeys.keys = sshKeys;
  };

  modules.homeManager.stellanova =
    { host ? { }, ... }:
    let
      identityFile = host.gitSshKey or (if (host.class or "nixos") == "darwin" then "~/.ssh/stellacode" else "/run/secrets/stellacode");
      ssh = hostName: {
        HostName = hostName;
        User = "stellanova";
        IdentityFile = identityFile;
        IdentitiesOnly = "yes";
      };
    in
    {
      programs.ssh.settings = {
        stellyrlab = ssh "stellyrlab.tailnet.stellyrland";
        stellyrland = ssh "stellyrland.tailnet.stellyrland";
      };
    };
}
