{ inputs, ... }: {
  # Bare necessities for any home-manager user, regardless of desktop environment.
  flake.modules.homeManager.basics = {
    imports = with inputs.self.modules.homeManager; [
      base
      cmdline
      mime
      xdg
      kitty
    ];
  };
}
