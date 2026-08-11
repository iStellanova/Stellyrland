{
  host,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings.env =
    lib.mapAttrsToList
      (name: value: {
        _args = [
          name
          value
        ];
      })
      (
        {
          HYPRCURSOR_THEME = "Bibata-Modern-Ice";
          HYPRCURSOR_SIZE = "16";
          XCURSOR_THEME = "Bibata-Modern-Ice";
          XCURSOR_SIZE = "16";
          GTK_THEME = "catppuccin-macchiato-sapphire-standard";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_QPA_PLATFORMTHEME = "gtk3";
          QT_STYLE_OVERRIDE = "kvantum";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          GTK_CSD = "0";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
          MOZ_ENABLE_WAYLAND = "1";
          OBS_USE_EGL = "1";
          PROTON_ENABLE_WAYLAND = "1";
        }
        // lib.optionalAttrs (host.graphics == "amd") {
          AMD_VULKAN_ICD = "RADV";
          RADV_PERFTEST = "nggc";
        }
        // lib.optionalAttrs (host.graphics == "nvidia") {
          # Cursor renders invisible/corrupted on the proprietary driver otherwise.
          WLR_NO_HARDWARE_CURSORS = "1";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          LIBVA_DRIVER_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
        }
      );
}
