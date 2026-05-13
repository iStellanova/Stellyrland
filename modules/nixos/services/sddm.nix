{ config, lib, pkgs, ... }:

let
  cfg = config.aspects.services.sddm;
in
{
  options.aspects.services.sddm.enable = lib.mkEnableOption "SDDM login manager with Catppuccin theme";

  config = lib.mkIf cfg.enable {
    services.accounts-daemon.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "catppuccin-macchiato-flamingo";
      settings = {
        General = {
          InputMethod = "";
        };
        Wayland = {
          CompositorCommand = let
            # A wrapper script that starts kwin and then forces rotation via kscreen-doctor
            kwinWrapper = pkgs.writeShellScript "sddm-kwin-wrapper" ''
              export KWIN_FORCE_SW_CURSOR=1
              export KWIN_DRM_NO_AMS=1
              # Use card paths to avoid PCI colon splitting bug in kwin
              export KWIN_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0
              export AQ_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0
              export AQ_NO_ATOMIC=1
              export XCURSOR_THEME=Bibata-Modern-Ice
              export XCURSOR_SIZE=16
              export XCURSOR_PATH=${pkgs.bibata-cursors}/share/icons
              export XDG_DATA_DIRS=$XDG_DATA_DIRS:${pkgs.bibata-cursors}/share

              # Create a local cursor config for the sddm user to be absolute sure
              mkdir -p $HOME/.icons/default
              echo "[Icon Theme]
              Inherits=Bibata-Modern-Ice" > $HOME/.icons/default/index.theme

              ${pkgs.kdePackages.kwin}/bin/kwin_wayland --no-lockscreen --no-global-shortcuts --locale1 &
              KWIN_PID=$!
              
              # Wait for the compositor to be ready
              sleep 3
              
              # Force rotation on the second monitor (Portrait)
              ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-3.rotation.left
              
              wait $KWIN_PID
            '';
          in
          "${kwinWrapper}";
        };
      };
    };

    # Cursor/Icons for the SDDM user profile
    users.users.sddm.packages = [ pkgs.bibata-cursors ];

    environment.systemPackages = [
      pkgs.bibata-cursors
      pkgs.kdePackages.libkscreen
      (pkgs.catppuccin-sddm.override {
        flavor = "macchiato";
        accent = "flamingo";
        font = "JetBrainsMono Nerd Font";
        fontSize = "12";
        background = "${../../../assets/login-wallpaper.png}";
        loginBackground = true;
      })
    ];

    # Ensure the user session starts correctly with Hyprland
    services.displayManager.defaultSession = lib.mkIf config.aspects.desktop.hyprland.enable "hyprland";

    # GPU & Backend Hardening (Fixes black screen/flickering/invisible cursor)
    systemd.services.display-manager.environment = {
      KWIN_DRM_DEVICES = "/dev/dri/by-path/pci-0000:03:00.0-card:/dev/dri/by-path/pci-0000:18:00.0-card";
      KWIN_FORCE_SW_CURSOR = "1";
      KWIN_DRM_NO_AMS = "1"; # Disable Atomic Mode Setting for cursor stability
      XCURSOR_THEME = "Bibata-Modern-Ice";
      XCURSOR_SIZE = "16";
      XCURSOR_PATH = "${pkgs.bibata-cursors}/share/icons";
    };

    # Enable Gnome Keyring for SDDM
    security.pam.services.sddm.enableGnomeKeyring = true;
  };
}
