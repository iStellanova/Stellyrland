{ config, lib, pkgs, identity, ... }:
{
  # In Dendritic, we can make core stuff a default, or make it an option.
  options.aspects.core.enable = lib.mkEnableOption "Core system configuration" // { default = true; };

  config = lib.mkIf config.aspects.core.enable {
    time.timeZone = if pkgs.stdenv.isDarwin then "America/Indiana/Indianapolis" else "America/Indianapolis";

    # Home Manager core settings
    home-manager.users.${identity.name} = {
      home.username = identity.name;
      home.homeDirectory = identity.home;
      home.stateVersion = "25.11";
      home.sessionPath = [ "$HOME/.local/state/nix/profiles/scratch/bin" ];
    };
  };
}
