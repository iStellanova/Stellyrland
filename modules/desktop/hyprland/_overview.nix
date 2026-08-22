# Built via mkHyprlandPlugin against nixpkgs's pkgs.hyprland (not the plugin's own flake,
# which pins its own independent, older Hyprland and breaks at runtime against ours).
# Source follows the flake.lock; a newer upstream revision can fail loudly if it
# outruns pkgs.hyprland's API.
{
  inputs,
  lib,
  lua,
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
          (lua ''hl.plugin.scrolloverview.overview("toggle")'')
        ];
      }
    ];
  };
}
