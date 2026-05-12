{ config, lib, identity, ... }:

{
  options.aspects.programs.noctalia-shell.enable = lib.mkEnableOption "Noctalia shell environment";

  config = lib.mkIf config.aspects.programs.noctalia-shell.enable {
    home-manager.users.${identity.name} = { inputs, ... }:
      {
        imports = [
          inputs.noctalia-shell.homeModules.default
          ./plugins.nix
          ./bar.nix
          ./launcher.nix
          ./control-center.nix
          ./appearance.nix
          ./system.nix
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
