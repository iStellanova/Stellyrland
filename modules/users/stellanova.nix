{den, ...}: {
  den.aspects.stellanova = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
      den.batteries.host-aspects

      # Cross-platform aspects
      den.aspects.core
      den.aspects.nix-settings
      den.aspects.vesktop
      den.aspects.nix-index
      den.aspects.kitty
      den.aspects.ns
      den.aspects.cli
      den.aspects.helix
      den.aspects.git
      den.aspects.yazi
      den.aspects.zed
      den.aspects.background-sounds
      den.aspects.cava
      den.aspects.media
      den.aspects.cloud-storage
      den.aspects.btop
      den.aspects.fastfetch
      den.aspects.browser
      den.aspects.zsh
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
