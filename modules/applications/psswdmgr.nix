_:
let
  osShared = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.proton-pass ];
  };
in
{
  flake.modules.nixos.psswdmgr = osShared;
  flake.modules.darwin.psswdmgr = osShared;
}
