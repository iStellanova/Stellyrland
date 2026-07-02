{ sn, ... }: {
  sn.productivity = {
    includes = [ sn.email ];
  };

  sn.email.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.protonmail-desktop ];
  };

  sn.email.darwin = _: {
    homebrew.casks = [ "proton-mail" ];
  };
}
