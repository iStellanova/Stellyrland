{ den, ... }: {
  den.aspects.stellanova = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
      den.batteries.host-aspects
    ];

    homeManager =
      {
        host,
        user,
        ...
      }:
      {
        home.username = user.name;
        home.homeDirectory = host.homeDir;
      };
  };
}
