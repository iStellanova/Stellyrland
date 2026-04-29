{ config, lib, pkgs, identity, ... }:
{
  options.aspects.programs.ns.enable = lib.mkEnableOption "Nix Search script";
  config = lib.mkIf config.aspects.programs.ns.enable {
    home-manager.users.${identity.name} = {
      home.packages = with pkgs; [
        (pkgs.writeShellApplication {
          name = "ns";
          runtimeInputs = with pkgs; [
            fzf
            nix-search-tv
            xdg-utils
          ];
          text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
        })
      ];
    };
  };
}
