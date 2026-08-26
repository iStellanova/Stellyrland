{
  flake.modules.finix.protonvpn =
    { host, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.proton-vpn ];
      preservation.preserveAt."/persist".users.${host.username}.directories = [ ".config/Proton/VPN" ];
    };

  flake.modules.nixos.protonvpn =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.proton-vpn ];
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [ ".config/Proton/VPN" ];
      };
    };

  flake.modules.darwin.protonvpn = {
    homebrew.casks = [ "protonvpn" ];
  };
}
