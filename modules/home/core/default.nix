{
  home.username = "stellanova";
  home.homeDirectory = "/home/stellanova";
  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings = {
      include.path = "~/.gitconfig-identity";
    };
  };
}
