{ config, lib, pkgs, identity, ... }:

{
  options.aspects.core.xdg.enable = lib.mkEnableOption "Core XDG settings" // { default = true; };

  config = lib.mkIf config.aspects.core.xdg.enable {
    environment.systemPackages = with pkgs; [
      xdg-user-dirs
      xdg-utils
    ];
    home-manager.users.${identity.name} = { config, ... }: {
      # Create the user directories if they don't exist.
      xdg.userDirs = {
        enable = true;
        setSessionVariables = true;
        createDirectories = true;
        desktop = "${config.home.homeDirectory}/Desktop";
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        music = "${config.home.homeDirectory}/Music";
        pictures = "${config.home.homeDirectory}/Pictures";
        publicShare = "${config.home.homeDirectory}/Public";
        templates = "${config.home.homeDirectory}/Templates";
        videos = "${config.home.homeDirectory}/Videos";
      };
      # Add the scratch profile to XDG data dirs to allow desktop entries and icons
      # from temporary nix-profile installations to be discovered by the shell.
      xdg.systemDirs.data = [
        "${config.home.homeDirectory}/.local/state/nix/profiles/scratch/share"
      ];
      # Default applications. Sets them to be used by default.
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/discord" = [ "vesktop.desktop" ];
          "x-scheme-handler/http" = [ "zen.desktop" ];
          "x-scheme-handler/https" = [ "zen.desktop" ];
          "x-scheme-handler/chrome" = [ "zen.desktop" ];
          "text/html" = [ "zen.desktop" ];
          "application/x-extension-htm" = [ "zen.desktop" ];
          "application/x-extension-html" = [ "zen.desktop" ];
          "application/x-extension-shtml" = [ "zen.desktop" ];
          "application/xhtml+xml" = [ "zen.desktop" ];
          "application/x-extension-xhtml" = [ "zen.desktop" ];
          "application/x-extension-xht" = [ "zen.desktop" ];
        };
      };
    };
  };
}
