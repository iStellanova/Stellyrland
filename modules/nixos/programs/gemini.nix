{ config, lib, pkgs, identity, ... }:

{
  options.aspects.programs.gemini.enable = lib.mkEnableOption "Gemini CLI AI agent";

  config = lib.mkIf config.aspects.programs.gemini.enable {
    home-manager.users.${identity.name} = {
      home.packages = [ pkgs.gemini-cli-bin ];
    };
  };
}
