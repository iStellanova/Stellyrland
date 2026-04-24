{ config, lib, pkgs, inputs, ... }:

{
  options.aspects.programs.browser.enable = lib.mkEnableOption "Zen Browser";

  config = lib.mkIf config.aspects.programs.browser.enable {
    home-manager.users.stellanova = {
      home.packages = [
        inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];
    };
  };
}
