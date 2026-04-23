{ config, lib, ... }:
{
  # In Dendritic, we can make core stuff a default, or make it an option.
  options.aspects.core.enable = lib.mkEnableOption "Core system configuration" // { default = true; };

  config = lib.mkIf config.aspects.core.enable {
    # NixOS core settings
    time.timeZone = "America/Indianapolis";
    i18n.defaultLocale = "en_US.UTF-8";
    security.sudo-rs = {
      enable = true;
      extraConfig = "Defaults pwfeedback";
    };
    system.stateVersion = "25.11";

    # Home Manager core settings
    home-manager.users.stellanova = {
      home.username = "stellanova";
      home.homeDirectory = "/home/stellanova";
      home.stateVersion = "25.11";
      home.sessionPath = [ "$HOME/.local/state/nix/profiles/scratch/bin" ];
    };
  };
}
