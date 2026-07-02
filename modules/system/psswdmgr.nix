{ sn, ... }: {
  sn.system = {
    includes = [ sn.psswdmgr ];
  };

  sn.psswdmgr.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.proton-pass ];
  };

  sn.psswdmgr.darwin = _: {
    homebrew.casks = [ "proton-pass" ];
  };
}
