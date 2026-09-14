{ ... }:
let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID23408QRe02peABnmkDcmpu2DVSwN3H+Jm7kcVenTDr stellanova"
  ];
in
{
  modules.nixos.stellanova = { lib, ... }: {
    users.users.stellanova = {
      openssh.authorizedKeys.keys = sshKeys;
      isNormalUser = true;
      home = "/home/stellanova";
      group = "stellanova";
      extraGroups = lib.mkDefault [ "wheel" ];
    };
    users.groups.stellanova = { };
  };

  modules.darwin.stellanova = {
    users.users.stellanova.openssh.authorizedKeys.keys = sshKeys;
  };
}
