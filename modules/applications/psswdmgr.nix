let
  osShared = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.proton-pass ];
  };
in
{
  modules.nixos.psswdmgr =
    { lib, host, ... }:
    {
      imports = [
        osShared
      ]
      ++ lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [ ".config/Proton Pass" ];
      };
    };
  modules.darwin.psswdmgr = osShared;
}
