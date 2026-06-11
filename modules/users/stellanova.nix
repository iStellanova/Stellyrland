{
  den,
  sn,
  ...
}: {
  den.aspects.stellanova = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
      den.batteries.host-aspects

      # Cross-platform aspects
      sn.core
      sn.nix-tools
      sn.vesktop
      sn.nix-index
      sn.kitty
      sn.ns
      sn.cli
      sn.helix
      sn.git
      sn.yazi
      sn.zed
      sn.background-sounds
      sn.cava
      sn.media
      sn.btop
      sn.fastfetch
      sn.zen-browser
      sn.zsh
    ];

    homeManager = {
      host,
      user,
      ...
    }: {
      home.username = user.name;
      home.homeDirectory = host.homeDir;
    };
  };
}
