_:
let
  psswdmgrModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.proton-pass ];
  };
in
{
  flake.modules.nixos.psswdmgr = psswdmgrModule;
  flake.modules.darwin.psswdmgr = psswdmgrModule;
}
