{ self, ... }:
{
  modules.nixos.accessor = {
    users.users.stellanova.openssh.authorizedKeys.keys = self.constants.sshKeys;
  };

  modules.darwin.accessor = {
    users.users.stellanova.openssh.authorizedKeys.keys = self.constants.sshKeys;
  };
}
