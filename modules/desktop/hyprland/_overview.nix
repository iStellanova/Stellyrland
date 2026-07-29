# Built via mkHyprlandPlugin against nixpkgs's pkgs.hyprland (not the plugin's own flake,
# which pins its own independent, older Hyprland and breaks at runtime against ours).
# Source tracks their `main` via `nix run .#write-tack` like any other input — no manual
# hash bumping. Hyprland bumps rebuild this automatically too; the only real risk is their
# `main` outrunning pkgs.hyprland's API (loud compile failure, not a hash problem).
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  scrolloverview = pkgs.hyprlandPlugins.mkHyprlandPlugin (_finalAttrs: {
    pluginName = "scrolloverview";
    version = "main";
    src = inputs.scroll-overview;

    nativeBuildInputs = [ pkgs.cmake ];
    buildInputs = [ pkgs.lua5_4 ];

    meta.license = lib.licenses.free;
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
