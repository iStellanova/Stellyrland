{ identity, ... }:

{
  system.stateVersion = 5;
  # Pull the Name from Identity Flake
  system.primaryUser = identity.name;

  # Program Aspects
  aspects = {
    darwin.system.enable = true;
    programs.aerospace.enable = true;
    darwin.homebrew.enable = true;
    core.fonts.enable = true;
    core.nix-settings.enable = true;
    programs.aesthetic.enable = true;
    programs.btop.enable = true;
    programs.cli.enable = true;
    programs.fastfetch.enable = true;
    programs.git.enable = true;
    programs.kitty.enable = true;
    programs.ns.enable = true;
    programs.yazi.enable = true;
    programs.zsh.enable = true;
    programs.neovim.enable = true;
    programs.gemini.enable = true;
    programs.vesktop.enable = true;
  };

  # Define the user so home-manager can link user packages correctly
  users.users.${identity.name} = {
    name = identity.name;
    home = identity.home;
  };
}
