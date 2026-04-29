{ config, lib, pkgs, identity, ... }:
{
  options.aspects.core.enable = lib.mkEnableOption "Core system configuration" // { default = true; };
  # Timezone based on whether the system is Darwin (macOS) or Linux. They're different in convention.
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
