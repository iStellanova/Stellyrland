{ inputs, ... }: {
  # Bare necessities for any new host, regardless of desktop/headless purpose.
  modules.nixos.base = {
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

  modules.darwin.base = {
    imports = with inputs.self.modules.darwin; [
      lix
      nix-settings
      openssh
      tailnet
      secrets
      users
    ];
  };

  modules.homeManager.base = {
    imports = with inputs.self.modules.homeManager; [
      core
      nix-tools
    ];
  };
}
