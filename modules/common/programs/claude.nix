{ config, lib, pkgs, identity, ... }:

{
  options.aspects.programs.claude.enable = lib.mkEnableOption "Claude AI agent";

  config = lib.mkIf config.aspects.programs.claude.enable {
    home-manager.users.${identity.name} = {
      home.packages = [ pkgs.claude-code ];
    };
  };
}
