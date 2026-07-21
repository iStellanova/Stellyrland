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

    settings.config.plugin.scrolloverview = {
      workspace_gap = 16;
      blur = true;
      shadow.enabled = true;
    };

    settings.bind = [
      {
        _args = [
          "SUPER + X"
          (lib.generators.mkLuaInline ''hl.plugin.scrolloverview.overview("toggle")'')
        ];
      }
    ];
  };
}
