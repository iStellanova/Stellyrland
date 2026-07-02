# TODO: Using myamusashi/hyprland-scroll-overview (fork) because the main repo (yayuuu) has not
# yet applied C++ source fixes for current Hyprland APIs (Monitor.hpp path, workspace/scheduleFrame
# API changes). When yayuuu merges those fixes, switch inputs.scroll-overview back to yayuuu.
#
# TODO: Hyprland version is currently controlled by the plugin's flake pin, not independently.
# Once Hyprland's API churn settles, consider re-pinning Hyprland separately and letting the
# plugin follow it instead.
#
# NOTE: pname override exists because upstream flake uses pname = "hyprland-scroll-overview" but
# installs libscrolloverview.so — the HM module derives the load path from pname, causing a
# mismatch. Remove the override if upstream fixes their flake.
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  pkg = inputs.scroll-overview.packages.${pkgs.stdenv.hostPlatform.system}.scrolloverview;
  scrolloverview = pkg.overrideAttrs (_: {
    pname = "scrolloverview";
  });
in {
  wayland.windowManager.hyprland = {
    plugins = [scrolloverview];

    settings.bind = [
      {
        _args = [
          "SUPER + X"
          (lib.generators.mkLuaInline ''
            function()
              if hl.plugin and hl.plugin.scrolloverview then
                hl.plugin.scrolloverview.overview("toggle")
              end
            end
          '')
        ];
      }
    ];
  };
}
