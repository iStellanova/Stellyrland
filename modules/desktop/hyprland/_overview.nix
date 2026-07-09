# Uses myamusashi/hyprland-scroll-overview (fork) — yayuuu's main repo hasn't merged the C++
# fixes for current Hyprland APIs yet. Switch back to yayuuu once it does.
#
# Hyprland plugins have no stable ABI across versions, so Hyprland is pinned via
# inputs.scroll-overview.inputs.hyprland (see default.nix) rather than independently.
# Building the plugin against a different Hyprland than its own pin fails with an
# undefined symbol at plugin load.
#
# pname override: upstream flake sets pname = "hyprland-scroll-overview" but installs
# libscrolloverview.so — the HM module derives the plugin's load path from pname, so
# without this override it can't find the .so. Remove if upstream fixes their flake.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  pkg = inputs.scroll-overview.packages.${pkgs.stdenv.hostPlatform.system}.scrolloverview;
  scrolloverview = pkg.overrideAttrs (_: {
    pname = "scrolloverview";
  });
in
{
  wayland.windowManager.hyprland = {
    plugins = [ scrolloverview ];

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
