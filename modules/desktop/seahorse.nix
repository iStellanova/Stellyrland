{ sn, ... }: {
  sn.desktop = {
    includes = [ sn.seahorse ];
  };

  sn.seahorse.nixos = _: {
    programs.seahorse.enable = true;
  };
}
