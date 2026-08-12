{ self, ... }:
{
  flake.modules.nixos.accessor = {
    users.users.stellanova.openssh.authorizedKeys.keys = self.constants.sshKeys;
  };

  flake.modules.darwin.accessor = {
    users.users.stellanova.openssh.authorizedKeys.keys = self.constants.sshKeys;
  };
}
