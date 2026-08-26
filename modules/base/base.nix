{ inputs, ... }: {
  # Bare necessities for any new host, regardless of desktop/headless purpose.
  flake.modules.nixos.base = {
    imports = with inputs.self.modules.nixos; [
      core
      lix
      nix-settings
      openssh
      tailnet
      secrets
      users
      avahi
    ];
  };

  flake.modules.finix.base = {
    imports = with inputs.self.modules.finix; [
      core
      lix
      nix-settings
      openssh
      tailnet
      secrets
      users
      avahi
    ];
  };

  flake.modules.darwin.base = {
    imports = with inputs.self.modules.darwin; [
      lix
      nix-settings
      openssh
      tailnet
      secrets
      users
    ];
  };

  flake.modules.homeManager.base = {
    imports = with inputs.self.modules.homeManager; [
      core
      nix-tools
    ];
  };
}
