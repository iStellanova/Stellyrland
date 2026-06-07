{inputs, ...}: {
  den.hosts.aarch64-darwin.stellyrtop = {
    username = "stellanova";
    homeDir = "/Users/stellanova";
    flakePath = "/Users/stellanova/Documents/GitHub/Stellyrland";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
    ];
    dataPath = inputs.my-assets;

    users.stellanova = {};
  };
}
