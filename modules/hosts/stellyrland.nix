{inputs ? {}, ...}: {
  flake-file.inputs.my-assets = {
    url = "github:iStellanova/Stellyrland/assets";
    flake = false;
  };

  den.hosts.x86_64-linux.stellyrland = {
    username = "stellanova";
    homeDir = "/home/stellanova";
    gitName = "stellanova";
    userEmail = "iStellanova@users.noreply.github.com";
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
    ];
    dataPath = inputs.my-assets;

    features = {
      secureBoot = true;
      hdr = true;
      coolerControl = true;
      lact = true;
    };

    users.stellanova = {};
  };
}
