{ config, lib, pkgs, inputs, identity, ... }:

{
  options.aspects.programs.browser.enable = lib.mkEnableOption "Zen Browser";

  config = lib.mkIf config.aspects.programs.browser.enable {
    home-manager.users.${identity.name} = {
      home.packages = [
        inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];
    };
  };
}
