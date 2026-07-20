{ inputs, ... }: {
  # Personal shell/CLI toolkit — not required for the system to function, but
  # wanted on every host regardless of desktop environment.
  flake.modules.nixos.cmdline = {
    imports = with inputs.self.modules.nixos; [
      zsh
      cli
    ];
  };

  flake.modules.darwin.cmdline = {
    imports = with inputs.self.modules.darwin; [
      zsh
      cli
    ];
  };

  flake.modules.homeManager.cmdline = {
    imports = with inputs.self.modules.homeManager; [
      zsh
      cli
      btop
    ];
  };
}
