{ inputs, ... }: {
  # Personal shell/CLI toolkit — not required for the system to function, but
  # wanted on every host regardless of desktop environment.
  modules.nixos.cmdline = {
    imports = with inputs.self.modules.nixos; [
      zsh
      cli
    ];
  };

  modules.darwin.cmdline = {
    imports = with inputs.self.modules.darwin; [
      zsh
      cli
    ];
  };

  modules.homeManager.cmdline = {
    imports = with inputs.self.modules.homeManager; [
      zsh
      cli
      btop
    ];
  };
}
