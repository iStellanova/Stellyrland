{ inputs, ... }: {
  flake.constants = {
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
    ];
    stellyrlabDeploymentKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRgqL5g6rGjR1yoD4XKOx/iHXJgYR9L6U4SU9sfOd7z stellyrlab deployment controller";
    dataPath = inputs.my-assets;
  };
}
