{ self, ... }:
{
  flake.modules.nixos.accessor = {
    users.users.stellanova.openssh.authorizedKeys.keys = self.constants.sshKeys;
    nix.settings.trusted-users = [ "stellanova" ];
    system.tools.nixos-rebuild.enableRun0Elevation = true;
  };

  flake.modules.darwin.accessor = {
    users.users.stellanova.openssh.authorizedKeys.keys = self.constants.sshKeys;
  };
}
