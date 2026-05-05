{ identity, ... }:

{
  system.stateVersion = 5;
  # Pull the Name from Identity Flake
  system.primaryUser = identity.name;

  # Enabled Aspects
  aspects = {
    darwin = {
      system.enable = true;
      homebrew.enable = true;
    };
    core = {
      fonts.enable = true;
      nix-settings.enable = true;
      networking.enable = true;
    };
    programs = {
      aerospace.enable = true;
      aesthetic.enable = true;
      btop.enable = true;
      cli.enable = true;
      fastfetch.enable = true;
      git.enable = true;
      kitty.enable = true;
      ns.enable = true;
      yazi.enable = true;
      zsh.enable = true;
      neovim.enable = true;
      gemini.enable = true;
      vesktop.enable = true;
    };
  };

  # Define the user so home-manager can link user packages correctly
  users.users.${identity.name} = {
    name = identity.name;
    home = identity.home;
  };
}
