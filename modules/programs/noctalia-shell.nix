{ config, lib, ... }:

{
  options.aspects.programs.noctalia-shell.enable = lib.mkEnableOption "Noctalia shell environment";

  config = lib.mkIf config.aspects.programs.noctalia-shell.enable {
    home-manager.users.stellanova = { inputs, pkgs, ... }: {
      imports = [
        inputs.noctalia-shell.homeModules.default
      ];

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = false;
      };

      # Link ONLY the nixos-monitor plugin so it is available to Noctalia.
      # We use force = true to ensure it overwrites any existing local version
      # with the one from the flake.
      xdg.configFile."noctalia/plugins/nixos-monitor" = {
        source = inputs.noctalia-nix-monitor;
        force = true;
      };
    };
  };
}
