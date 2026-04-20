{
  home.username = "stellanova";
  home.homeDirectory = "/home/stellanova";
  home.stateVersion = "25.11";

  home.sessionPath = [ "$HOME/.local/state/nix/profiles/scratch/bin" ];

  programs.git = {
    enable = true;
    settings = {
      include.path = "~/.gitconfig-identity";
    };
  };
}
