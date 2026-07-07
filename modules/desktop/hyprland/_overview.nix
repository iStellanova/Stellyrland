# SHELVED: scroll-overview plugin is unstable. The myamusashi fork is being actively
# rebased — newer commits break against their own pinned Hyprland (missing AnimationManager.hpp).
# The only known-working commit (bcd9eb9) was pinned manually; it's not in remote history anymore.
# Holding Hyprland hostage to the plugin pin wasn't worth it given the fork instability.
#
# To re-enable:
#   1. In default.nix: uncomment the flake-file.inputs.scroll-overview block and re-add ./_overview.nix to imports
#   2. Run: tack update scroll-overview  (find a commit that actually compiles)
#   3. Remove Hyprland's independent pin if locking them together again
#
# TODO: Switch inputs.scroll-overview to yayuuu/hyprland-scroll-overview once that repo applies
# the C++ fixes (Monitor.hpp path, workspace/scheduleFrame API changes).
#
# NOTE: pname override: upstream uses pname = "hyprland-scroll-overview" but installs
# libscrolloverview.so — HM derives the load path from pname, causing a mismatch.
# Remove if upstream fixes their flake.
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
