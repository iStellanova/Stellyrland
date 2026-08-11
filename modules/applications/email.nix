_: {
  flake.modules.nixos.email =
    {
      lib,
      host,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.protonmail-desktop ];
      imports = lib.optional (host.persistence or false) {
        preservation.preserveAt."/persist".users.${host.username}.directories = [ ".config/Proton Mail" ];
      };
    };

  flake.modules.darwin.email = _: {
    homebrew.casks = [ "proton-mail" ];
  };
}
