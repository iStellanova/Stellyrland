{ inputs, ... }: {
  # --- System CLI Aspects ---
  flake.modules.nixos.system-cli = {
    imports = with inputs.self.modules.nixos; [
      core
      lix
      nix-settings
      cli
      openssh
      tailscale
      zsh
      maintenance
      mime
      secrets
      services-base
      system-tools
      users
      xdg
    ];
  };

  flake.modules.darwin.system-cli = {
    imports = with inputs.self.modules.darwin; [
      lix
      nix-settings
      cli
      tailscale
      zsh
      darwindefs
      homebrew
      maintenance
      secrets
      users
    ];
  };

  flake.modules.homeManager.system-cli = {
    imports = with inputs.self.modules.homeManager; [
      core
      nix-tools
      mime
      xdg
      btop
      cli
      fastfetch
      kitty
      zsh
    ];
  };

  # --- System Desktop Aspects ---
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      easyeffects
      fonts
      hyprland
      noctalia-greeter
      noctalia-shell
      pipewire
      catppuccin
      openrgb
      aesthetic
    ];
  };

  flake.modules.darwin.system-desktop = {
    imports = with inputs.self.modules.darwin; [
      system-cli
      hiro
      kitty
      aesthetic
      fonts
    ];
  };

  flake.modules.homeManager.system-desktop-nixos = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
      easyeffects
      noctalia-shell
      openrgb
      hyprland
      catppuccin
    ];
  };

  flake.modules.homeManager.system-desktop-darwin = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
      hiro
      catppuccin
    ];
  };
}
