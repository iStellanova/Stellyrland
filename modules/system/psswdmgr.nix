{ sn, ... }: {
  sn.system = {
    includes = [ sn.psswdmgr ];
  };

  sn.psswdmgr.os = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.proton-pass ];
  };
}
