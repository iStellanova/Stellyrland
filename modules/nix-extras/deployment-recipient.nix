{ self, ... }:
{
  flake.modules.nixos.deployment-recipient = _: {
    users.users.stellanova.openssh.authorizedKeys.keys = [
      self.constants.stellyrlabDeploymentKey
    ];
    nix.settings.trusted-users = [ "stellanova" ];
    system.tools.nixos-rebuild.enableRun0Elevation = true;
  };
}
