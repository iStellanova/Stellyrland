{identity, ...}: {
  system.stateVersion = 5;
  # Pull the Name from Identity Flake
  system.primaryUser = identity.name;

  # Networking
  networking.computerName = "Stellyrtop";
  networking.hostName = "stellyrtop";
  networking.localHostName = "stellyrtop";

  # Enabled Aspects
  aspects = {
    darwin = {
      system.enable = true;
      homebrew.enable = true;
    };
    core = {
      enable = true;
      fonts.enable = true;
      nix-settings.enable = true;
      networking.enable = true;
    };
    programs = {
      aerospace.enable = true;
      aesthetic.enable = true;
      antigravity.enable = true;
      browser.enable = true;
      btop.enable = true;
      cava.enable = true;
      cli.enable = true;
      fastfetch.enable = true;
      gaming.enable = true;
      git.enable = true;
      kitty.enable = true;
      nix-index.enable = true;
      ns.enable = true;
      yazi.enable = true;
      zsh.enable = true;
      neovim.enable = true;
      claude.enable = true;
      vesktop.enable = true;
      zed.enable = true;
    };
  };

  # Define the user so home-manager can link user packages correctly
  users.users.${identity.name} = {
    name = identity.name;
    home = identity.home;
  };
}
